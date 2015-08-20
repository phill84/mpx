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

    var uiView: ControlUIView?
    var titleView: TitleView?
    var currentSize: NSRect?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.backgroundColor = NSColor.blackColor()
    
		AppDelegate.getInstance().playerWindowController = self
        
        // get default size
        currentSize = self.window?.frame
        
        // determine UI views
        for obj in window!.contentView.subviews {
            if obj is ControlUIView {
                self.uiView = obj as? ControlUIView
            }
        }
        
        center()
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if AppDelegate.getInstance().active {
            uiView?.animator().alphaValue = 1
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        uiView?.animator().alphaValue = 0
    }

    
    func resize(#width: Int, height: Int) {
        let visibleFrame = NSScreen.mainScreen()?.visibleFrame
        let size = NSSize(width: width, height: height)
        
        // cap new size to main screen resolution
        // while preserving the aspect ratio
        var h = CGFloat(size.height)
        var w = CGFloat(size.width)
        var ar = w / h
        
        var maxHeight = visibleFrame!.height// - menuBarHeight!
        
        if (h > maxHeight) {
            h = maxHeight
            w = h * ar
        }
        if (w > visibleFrame!.width) {
            w = visibleFrame!.width
            h = w / ar
        }
        
        // don't do anything if currentSize is the same
        if currentSize?.width == w && currentSize?.height == h {
            return
        }
        
        // resize NSWindow with animation
        let xOffset = (visibleFrame!.width - w) / 2
        let yOffset = (visibleFrame!.height - h) / 2 + visibleFrame!.origin.y
        
        let frame = NSRect(x: xOffset, y: yOffset, width: w, height: h)
        
        
        dispatch_async(dispatch_get_main_queue(), {
            self.window?.setFrame(frame, display: true, animate: true)
        })
    }
    
    func center() {
        let visibleFrame = NSScreen.mainScreen()?.visibleFrame
        let x = (visibleFrame!.width - self.window!.frame.width) / 2
        let y = (visibleFrame!.height - self.window!.frame.height) / 2 + visibleFrame!.origin.y
        self.window!.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    func alertAndExit(error: String) {
        let alert = NSAlert()
        alert.addButtonWithTitle("OK")
        alert.messageText = "Failed to initialize mpv"
        alert.informativeText = error
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        if alert.runModal() == NSAlertFirstButtonReturn {
            NSApplication.sharedApplication().terminate(alert)
        }
    }
}
