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
	
    var active = false;
    
	var playerWindowController: PlayerWindowController?
	var mpv: MpvController?

	func applicationDidFinishLaunching(notification: NSNotification) {
		// Initialize controllers
		mpv = MpvController()
        
	}

	func applicationWillTerminate(notification: NSNotification) {
		// Insert code here to tear down your application
	}
    
    func applicationDidBecomeActive(notification: NSNotification) {
        active = true
    }
    
    func applicationDidResignActive(notification: NSNotification) {
        active = false
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
			self.mpv?.openMediaFiles(openPanel.URLs.first! as! NSURL)
		}
	}
}

