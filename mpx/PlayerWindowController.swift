//
//  PlayerWindowController.swift
//  mpx
//
//  Created by Jiening Wen on 08/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import AppKit
import Cocoa
import XCGLogger

class PlayerWindowController: NSWindowController {
    
    let logger = XCGLogger.defaultInstance()
    let screenSize = NSScreen.mainScreen()?.frame
    let menuBarHeight = NSApplication.sharedApplication().mainMenu?.menuBarHeight

    var uiView: ControlUIView?
    var titleView: TitleView?
    var currentSize: NSRect?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
		AppDelegate.getInstance().playerWindowController = self
        
        // get default size
        currentSize = self.window?.frame
        
        // determine UI views
        for obj in window!.contentView.subviews {
            if obj is ControlUIView {
                self.uiView = obj as? ControlUIView
            }
        }
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
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.window?.setFrame(frame, display: true, animate: true)
            CATransaction.commit()
        })
    }
    
    override func mouseEntered(theEvent: NSEvent) {
//        logger.debug("fade in ui view")
        uiView?.animator().alphaValue = 1
    }

    override func mouseExited(theEvent: NSEvent) {
//        logger.debug("fade out ui view")
        uiView?.animator().alphaValue = 0
    }

}
