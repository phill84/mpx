//
//  PlayerViewController.swift
//  mpx
//
//  Created by Jiening Wen on 04/09/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class PlayerViewController: NSViewController {

	let logger = XCGLogger.defaultInstance()
	let idleInterval = NSTimeInterval(2) // 2 seconds
	
	var titleBarView: NSView?
	var controlUIView: ControlUIView?
	var idleTimer: NSTimer?
	weak var mpv: MpvController?
	
	var cursorOverView = false
	
	override func viewWillAppear() {
		titleBarView = view.window!.standardWindowButton(NSWindowButton.CloseButton)?.superview
		controlUIView = view.subviews[1] as? ControlUIView
		resetIdleTimer()
		
		mpv = (view.window?.windowController() as! PlayerWindowController).mpv
	}
	
	override func mouseEntered(event: NSEvent) {
		cursorOverView = true
		showControlUI()
	}
	
	override func mouseExited(event: NSEvent) {
		cursorOverView = false
		if !AppDelegate.getInstance().fullscreen {
			hideControlUI()
		}
		NSCursor.unhide()
	}
	
	override func mouseMoved(event: NSEvent) {
		showControlUI()
	}
	
	func resetIdleTimer() {
		self.idleTimer?.invalidate()
		self.idleTimer = NSTimer(timeInterval: self.idleInterval, target: self, selector: Selector("hideControlUI"), userInfo: nil, repeats: true)
		NSRunLoop.mainRunLoop().addTimer(self.idleTimer!, forMode: NSDefaultRunLoopMode)
	}
	
	func showControlUI() {
		if !AppDelegate.getInstance().active {
			return
		}
		
		resetIdleTimer()
		titleBarView!.animator().alphaValue = 1
		controlUIView!.animator().alphaValue = 1
		// unhide cursor always since it doesn't do any harm if already unhidden
		NSCursor.unhide()
	}
	
	func hideControlUI() {
		if !AppDelegate.getInstance().active {
			return
		}
		
		// invalidate idleTimer since controlUI will be hidden already
		idleTimer?.invalidate()
		if !AppDelegate.getInstance().fullscreen {
			titleBarView!.animator().alphaValue = 0
			
		}
		controlUIView!.animator().alphaValue = 0
		// hide cursor if over player view
		if cursorOverView {
			NSCursor.hide()
		}
	}
}
