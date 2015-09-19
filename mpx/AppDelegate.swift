//
//  AppDelegate.swift
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
import XCGLogger

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let logger = XCGLogger.defaultInstance()
	
    var active = false
    var fullscreen = false
    var mediaFileLoaded = false
    
	var mpv: MpvController?
    var playerWindowController: PlayerWindowController?
    
    static func getInstance() -> AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }
    
	func applicationDidFinishLaunching(notification: NSNotification) {
		// set up default logger
		#if DEBUG
			logger.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
		#else
			logger.setup(.Severe, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
		#endif
		
        // change appearance to vibrant dark
        let playerWindow = NSApplication.sharedApplication().windows[0] as! PlayerWindow
        playerWindow.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        playerWindow.orderOut(self)
        
        playerWindowController = playerWindow.windowController as? PlayerWindowController
        
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
	
	@IBAction func openMediaFile(sender: AnyObject) {
		let openPanel = NSOpenPanel()
		
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.resolvesAliases = false
		openPanel.canCreateDirectories = false
		openPanel.allowsMultipleSelection = false
		
		openPanel.title = "Open Media File"
		
		if (openPanel.runModal() == NSFileHandlingPanelOKButton) {
			self.logger.debug(openPanel.URLs.debugDescription)
			self.mpv?.openMediaFiles(openPanel.URLs.first! )
		}
	}

    @IBAction func resizeHalf(sender: AnyObject) {
        playerWindowController!.resizeHalf()
    }
    
    @IBAction func resizeOriginal(sender: NSMenuItem) {
        playerWindowController!.resizeOriginal()
    }
    
    @IBAction func resizeDouble(sender: AnyObject) {
        playerWindowController!.resizeDouble()
    }
}

