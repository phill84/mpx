//
//  MpvController.swift
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import Foundation
import XCGLogger

class MpvController: NSObject {
	
	let logger = XCGLogger.defaultInstance()
	
	var context: COpaquePointer?
	var mpvQueue: dispatch_queue_t?
	
	override init() {
		super.init()
		
		// initialize mpv
		context = mpv_create()
		if (context == nil) {
            let error = "failed to create mpv context"
			logger.severe(error)
			AppDelegate.getInstance().playerWindowController?.alertAndExit(error)
		}
		logger.debug("mpv context created: \(self.context!.debugDescription)")
		
		checkError(mpv_initialize(context!))
		checkError(mpv_request_log_messages(context!, "warn"))
		
		mpvQueue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL)
		
        // set default options
        var videoView: AnyObject? = AppDelegate.getInstance().playerWindowController?.window?.contentView.subviews[0]
        checkError(mpv_set_option(context!, "wid", MPV_FORMAT_INT64, &videoView))
        checkError(mpv_set_option_string(context!, "audio-client-name", "mpx"))
        checkError(mpv_set_option_string(context!, "hwdec", "auto"))
        checkError(mpv_set_option_string(context!, "hwdec-codecs", "all"))

        
		// register callbacks
		mpv_set_wakeup_callback(context!, getWakeupCallback(), unsafeBitCast(self, UnsafeMutablePointer<Void>.self));
	}
	
	func getWakeupCallback() -> CFunctionPointer<(UnsafeMutablePointer<Void> -> Void)> {
		let block : @objc_block (UnsafeMutablePointer<Void>) -> Void = { (context) in
			let mpvController = unsafeBitCast(context, MpvController.self)
			mpvController.readEvents()
		}
		let imp : COpaquePointer = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
		let callback = CFunctionPointer<(UnsafeMutablePointer<Void> -> Void)>(imp)
		return callback
	}
	
	func checkError(status: Int32) {
		if (status < 0) {
            let error = String.fromCString(mpv_error_string(status))!
			logger.error("mpv API error: \(error)")
            AppDelegate.getInstance().playerWindowController?.alertAndExit(error)
		}
	}
	
	func readEvents() {
		dispatch_async(mpvQueue!, {
			while (self.context != nil) {
				let event = mpv_wait_event(self.context!, 0).memory

				let event_id = event.event_id.value
				if (event_id == MPV_EVENT_NONE.value) {
					break
				}
				self.handleEvent(event)
			}
		})
	}
	
	func handleEvent(event: mpv_event) {
		switch event.event_id.value {
		case MPV_EVENT_SHUTDOWN.value:
			logger.debug("mpv shutdown")
			
		case MPV_EVENT_LOG_MESSAGE.value:
			let msg = UnsafeMutablePointer<mpv_event_log_message>(event.data).memory
			let prefix = String.fromCString(msg.prefix)!
			let level = String.fromCString(msg.level)!
			var text = String.fromCString(msg.text)!
            text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if !text.isEmpty {
                logger.debug("[\(prefix)] \(level): \(text)")
            }
        
			
		case MPV_EVENT_FILE_LOADED.value:
			var videoParams: mpv_node?
			mpv_get_property(context!, "video-params", MPV_FORMAT_NODE, &videoParams)
			
			if (videoParams == nil) {
				return
			}
			
			var dict = get_mpv_node_list_as_dict(videoParams!) as! Dictionary<String, AnyObject>
			var w: Int = dict["w"] as! Int
			var h: Int = dict["h"] as! Int
			
			logger.debug("original resolution: \(w)x\(h)")
			AppDelegate.getInstance().playerWindowController?.resize(width: w, height: h)

        case MPV_EVENT_PLAYBACK_RESTART.value:
            logger.debug("playback restart")

		default:
			let eventName = String.fromCString(mpv_event_name(event.event_id))!
			logger.debug("event name: \(eventName)")
            if event.data != nil {
                logger.debug("event data: \(event.data)")
            }
			
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
			mpv_command(self.context!, &cmd)
		})
	}
}