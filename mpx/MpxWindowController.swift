//
//  MpxWindowController.swift
//  mpx
//
//  Created by Jiening Wen on 08/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class MpxWindowController: NSWindowController {
    
    let logger = XCGLogger.defaultInstance()
    let screenSize = NSScreen.mainScreen()?.frame
    let menuBarHeight = NSApplication.sharedApplication().mainMenu?.menuBarHeight

    var uiController: MpxUIWindowController?
    var currentSize: NSRect?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
		AppDelegate.getInstance().mpxWindowController = self
        
        // get default size
        currentSize = self.window?.frame
        
        // add UI window as a child window above video window
        uiController = MpxUIWindowController(windowNibName: "MpxUIWindow")
        self.window?.addChildWindow(uiController!.window!, ordered: NSWindowOrderingMode.Above)
    }
    
    func resize(#width: Int, height: Int) {
        let size = NSSize(width: width, height: height)
        
        // cap new size to main screen resolution
        // while preserving the aspect ratio
        var h = CGFloat(size.height)
        var w = CGFloat(size.width)
        var ar = w / h
        
        var maxHeight = screenSize!.height - menuBarHeight!
        
        if (h > maxHeight) {
            h = maxHeight
            w = h * ar
        }
        if (w > screenSize!.width) {
            w = screenSize!.width
            h = w / ar
        }
        
        // don't do anything if currentSize is the same
        if currentSize?.width == w && currentSize?.height == h {
            return
        }
        
        // resize NSWindow with animation
        let xOffset = (self.screenSize!.width - w) / 2
        let yOffset = (self.screenSize!.height - h) / 2
        
        let frame = NSRect(x: xOffset, y: yOffset, width: w, height: h)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.window?.setFrame(frame, display: true, animate: false)
            self.uiController!.window?.setFrame(frame, display: true, animate: false)
        })
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        logger.debug("mouse entered")
    }

    override func mouseExited(theEvent: NSEvent) {
        logger.debug("mouse exited")
    }

}
