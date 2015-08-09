//
//  MpvPlayerController.swift
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import Foundation
import XCGLogger

class MpvPlayerController: NSObject {
	
	let logger = XCGLogger.defaultInstance()
	
	var context: COpaquePointer?
	var mpvQueue: dispatch_queue_t?
	
	override init() {
		super.init()
		
		// initialize mpv
		context = mpv_create()
		if (context == nil) {
			logger.severe("failed to create mpv context")
			return
		}
		logger.debug("mpv context created: \(self.context!.debugDescription)")
		
		checkError(mpv_initialize(context!))
		checkError(mpv_request_log_messages(context!, "warn"))
		
		mpvQueue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL)
		
		// set up opengl
		checkError(mpv_set_option_string(context!, "vo", "opengl-cb"))
		var openGLContext = mpv_get_sub_api(context!, MPV_SUB_API_OPENGL_CB)
		if (openGLContext == nil) {
			logger.severe("libmpv does not have the opengl-cb sub-API.")
			return
		}
		logger.debug("mpv openGL context created: \(openGLContext.debugDescription)")
		
		var openGLView = AppDelegate.getInstance().mpvView?.view.subviews.first as! MpvClientOGLView
		
		// register callbacks
		openGLView.mpvOGLContext = openGLContext
 		var r = mpv_opengl_cb_init_gl(COpaquePointer(openGLContext), nil, get_proc_address_fn(), nil)
		if (r < 0) {
			logger.severe("gl init has failed.")
		}
		mpv_opengl_cb_set_update_callback(COpaquePointer(openGLContext), get_update_fn(), unsafeBitCast(self, UnsafeMutablePointer<Void>.self))
		
		
		mpv_set_wakeup_callback(context!, getWakeupCallback(), unsafeBitCast(self, UnsafeMutablePointer<Void>.self));
	}
	
	func getWakeupCallback() -> CFunctionPointer<(UnsafeMutablePointer<Void> -> Void)> {
		let block : @objc_block (UnsafeMutablePointer<Void>) -> Void = { (context) in
			let playerController = unsafeBitCast(context, MpvPlayerController.self)
			playerController.readEvents()
		}
		let imp : COpaquePointer = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
		let callback = CFunctionPointer<(UnsafeMutablePointer<Void> -> Void)>(imp)
		return callback
	}
	
	func checkError(status: Int32) {
		if (status < 0) {
			logger.error("mpv API error: \(String.fromCString(mpv_error_string(status))!)")
		}
	}
	
	func drawRect() {
		if (AppDelegate.getInstance().openGLView != nil) {
			AppDelegate.getInstance().openGLView!.drawRect()
		}
	}
	
	func readEvents() {
		logger.debug("reading events")
		
		dispatch_async(mpvQueue!, {
			while (self.context != nil) {
				let event = mpv_wait_event(self.context!, 0).memory

				let event_id = event.event_id.value
				self.logger.debug("event_id: \(event_id)")
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
			let msg = unsafeBitCast(event.data, mpv_event_log_message.self)
			let prefix = String.fromCString(msg.prefix)!
			let level = String.fromCString(msg.level)!
			let text = String.fromCString(msg.text)!
			logger.debug("[\(prefix)] \(level): \(text)")
			
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
			AppDelegate.getInstance().resizeVideo(width: w, height: h)
			
		default:
			let eventName = String.fromCString(mpv_event_name(event.event_id))!
			logger.debug("event name: \(eventName)")
			
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