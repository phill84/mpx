//
//  AppDelegate.swift
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let logger = XCGLogger.defaultInstance()
	let screenSize = NSScreen.mainScreen()?.frame
	
	var mpvWindow: MpvWindowController?
	var mpvView: MpvViewController?
	var openGLView: MpvClientOGLView?
	var player: MpvPlayerController?
	var menuBarHeight: CGFloat?

	func applicationDidFinishLaunching(aNotification: NSNotification) {

		// Initialize mpv player
		player = MpvPlayerController()
		menuBarHeight = NSApplication.sharedApplication().mainMenu?.menuBarHeight
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	static func getInstance() -> AppDelegate {
		return NSApplication.sharedApplication().delegate as! AppDelegate
	}
	
	@IBAction func openMediaFile(sender: AnyObject) {
		var openPanel = NSOpenPanel()
		
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.resolvesAliases = false
		openPanel.canCreateDirectories = false
		openPanel.allowsMultipleSelection = false
		
		openPanel.title = "Open Media File"
		
		if (openPanel.runModal() == NSFileHandlingPanelOKButton) {
			self.logger.debug(openPanel.URLs.debugDescription)
			self.player?.openMediaFiles(openPanel.URLs.first! as! NSURL)
		}
	}
	
	
	func resizeVideo(#width: Int, height: Int) {
		let size = NSSize(width: width, height: height)
		
		// cap new size to main screen resolution
		// while preserving the aspect ratio
		var fh = CGFloat(size.height)
		var fw = CGFloat(size.width)
		var ar = fw / fh
		
		var maxHeight = screenSize!.height - menuBarHeight!
		
		if (fh > maxHeight) {
			fh = maxHeight
			fw = fh * ar
		}
		if (fw > screenSize!.width) {
			fw = screenSize!.width
			fh = fw / ar
		}
		// resize NSWindow with animation
		let xOffset = (self.screenSize!.width - fw) / 2
		let yOffset = (self.screenSize!.height - fh) / 2
		
		let frame = NSRect(x: xOffset, y: yOffset, width: fw, height: fh)
		
		dispatch_async(dispatch_get_main_queue(), {
			self.mpvWindow!.window?.setFrame(frame, display: true, animate: false)
			
			// resize all views
			let contentView = self.mpvWindow?.window!.contentView as! NSView
			contentView.setFrameSize(size)
			for subview in contentView.subviews {
				if subview is NSView {
					let subNSView = subview as! NSView
					subNSView.setFrameSize(size)
					subNSView.setFrameOrigin(NSPoint(x: 0, y: 0))
				}
			}
		})
	}
	

}

