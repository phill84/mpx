//
//  MpvController.swift
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
//  Copyright (c) 2015 phill84.
//
//  This file is part of mpx.
//
//  mpx is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  mpx is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with mpx.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa
import Foundation
import XCGLogger

class MpvController: NSObject {
	
	let logger = XCGLogger.defaultInstance()
    let playerWindowController: PlayerWindowController
	
	var context: COpaquePointer?
	var mpvQueue: dispatch_queue_t?
    var videoOriginalSize: NSSize?
    
    var state: PlayerState = .Uninitialized
	var playlist = 0
	
	override init() {
        playerWindowController = NSApplication.sharedApplication().windows[0].windowController as! PlayerWindowController
		super.init()
        playerWindowController.mpv = self
        
		// initialize mpv
		context = mpv_create()
		if (context == nil) {
            let error = "failed to create mpv context"
			logger.severe(error)
			playerWindowController.alertAndExit(error)
		}
		logger.debug("mpv context created: \(context!.debugDescription)")
		
		checkError(mpv_initialize(context!), message: "mpv_initialize")
		#if DEBUG
			checkError(mpv_request_log_messages(context!, "info"), message: "mpv_request_log_messages")
		#else
			checkError(mpv_request_log_messages(context!, "warn"), message: "mpv_request_log_messages")
		#endif
		
		mpvQueue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL)
		
        // set default options
        var videoView: AnyObject? = playerWindowController.window?.contentView!.subviews[0]
		checkError(mpv_set_option(context!, "wid", MPV_FORMAT_INT64, &videoView), message: "mpv_set_option: wid")
		checkError(mpv_set_option_string(context!, "audio-client-name", "mpx"), message: "mpv_set_option_string: audio-client-name")
        checkError(mpv_set_option_string(context!, "hwdec", "auto"), message: "mpv_set_option_string: hwdec")
        checkError(mpv_set_option_string(context!, "hwdec-codecs", "all"), message: "mpv_set_option_string: hwdec-codecs")

        
		// register callbacks
		func callback(context: UnsafeMutablePointer<Void>) -> Void {
			let mpvController = unsafeBitCast(context, MpvController.self)
			mpvController.readEvents()
		}
		mpv_set_wakeup_callback(context!, callback,	unsafeBitCast(self, UnsafeMutablePointer<Void>.self));
        state = .Initialized
	}
	
	func checkError(status: Int32, message: String) {
		if (status < 0) {
            let error = String.fromCString(mpv_error_string(status))!
			logger.error("mpv API error: \(error), \(message)")
            playerWindowController.alertAndExit(error)
		}
	}
	
	func readEvents() {
		dispatch_async(mpvQueue!, {
			while (self.context != nil) {
				let event = mpv_wait_event(self.context!, 0).memory

				let event_id = event.event_id.rawValue
				if (event_id == MPV_EVENT_NONE.rawValue) {
					break
				}
				self.handleEvent(event)
			}
		})
	}
	
	func handleEvent(event: mpv_event) {
		switch event.event_id.rawValue {
        case MPV_EVENT_IDLE.rawValue:
            state = .Idle
            
		case MPV_EVENT_SHUTDOWN.rawValue:
			logger.debug("mpv shutdown")
			
		case MPV_EVENT_LOG_MESSAGE.rawValue:
			let msg = UnsafeMutablePointer<mpv_event_log_message>(event.data).memory
			let prefix = String.fromCString(msg.prefix)!
			let level = String.fromCString(msg.level)!
			var text = String.fromCString(msg.text)!
            text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if !text.isEmpty {
                NSLog("[\(prefix)] \(level): \(text)")
            }
			
		case MPV_EVENT_FILE_LOADED.rawValue:
			logger.debug("file loaded")
            state = .FileLoaded
            
            // get video size and resize if necessary
            videoOriginalSize = getVideoSize()
            if AppDelegate.getInstance().fullscreen {
                let mainFrame = NSScreen.mainScreen()!.frame
                playerWindowController.resize(width: mainFrame.width, height: mainFrame.height)
            } else {
                playerWindowController.resize(width: videoOriginalSize!.width, height: videoOriginalSize!.height)
            }
            playerWindowController.showWindow()
            AppDelegate.getInstance().mediaFileLoaded = true
            
            // update window title
            if let title = getVideoTitle() {
                playerWindowController.updateTitle(title)
            }

        case MPV_EVENT_PLAYBACK_RESTART.rawValue:
			state = isPaused() ? .Paused : .Playing
            logger.debug("playback restarted")

		case MPV_EVENT_PAUSE.rawValue:
			state = .Paused
			logger.debug("playback paused")
		
		case MPV_EVENT_UNPAUSE.rawValue:
			state = .Playing
			logger.debug("playback unpaused")
		
		case MPV_EVENT_END_FILE.rawValue:
			playlist--
			let data = UnsafeMutablePointer<mpv_event_end_file>(event.data).memory
			switch UInt32(data.reason) {
			case MPV_END_FILE_REASON_ERROR.rawValue:
				let error = String.fromCString(mpv_error_string(data.error))!
				logger.error("end file: \(error)")
			default:
				logger.debug("end file: \(data.reason)")
			}
			if playlist == 0 {
				NSApplication.sharedApplication().stop(self)
			}
			
		default:
			let eventName = String.fromCString(mpv_event_name(event.event_id))!
			logger.debug("event name: \(eventName), error: \(event.error), data: \(event.data), reply userdata: \(event.reply_userdata)")
		}
	}
	
    func getVideoSize() -> NSSize? {
        var videoParams: mpv_node?
        mpv_get_property(context!, "video-params", MPV_FORMAT_NODE, &videoParams)
        
        if (videoParams == nil) {
            return nil
        }
        
        let dict = get_mpv_node_list_as_dict(videoParams!) as! Dictionary<String, AnyObject>
        let w: Int = dict["w"] as! Int
        let h: Int = dict["h"] as! Int
        
        logger.debug("original resolution: \(w)x\(h)")
        return NSSize(width: w, height: h)
    }
    
    func getVideoTitle() -> String? {
        let title = mpv_get_property_string(context!, "media-title")
        if title == nil {
            return nil
        } else {
            return String.fromCString(title)
        }
    }
    
	func openMediaFiles(url: NSURL) {
		dispatch_async(mpvQueue!, {
			self.logger.debug("attempt to open \(url.debugDescription)")
			var cmd = [
				("loadfile" as NSString).UTF8String,
				(url.path! as NSString).UTF8String,
				nil
			]
			self.playlist++
			mpv_command(self.context!, &cmd)
		})
	}
	
	func isPaused() -> Bool {
		var flag: Int?
		mpv_get_property(context!, "pause", MPV_FORMAT_FLAG, &flag)
		
		if (flag == nil) {
			return false
		}
		return flag == 1
	}
	
	func togglePause() {
		var pause = 1
		
		if state == .Playing {
			pause = 1
		} else if state == .Paused {
			pause = 0
		}
		mpv_set_property_async(context!, 0, "pause", MPV_FORMAT_FLAG, &pause);
	}
	
	func seekBySecond(seconds: Int) {
		let values: [AnyObject] = [
			"osd-msg",
			"seek",
			seconds
		]
		var mpv_formats: [mpv_format] = [
			MPV_FORMAT_STRING,
			MPV_FORMAT_STRING,
			MPV_FORMAT_INT64
		]
		
		mpv_cmd_node_async(context!, values, &mpv_formats)
	}
}