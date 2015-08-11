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
	
	var mpxWindowController: MpxWindowController?
	var openGLView: MpvClientOGLView?
	var player: MpvPlayerController?
	

	func applicationDidFinishLaunching(aNotification: NSNotification) {        
		// Initialize controllers
		player = MpvPlayerController()
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
}

