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

class PlayerWindowController: NSWindowController, NSWindowDelegate {
    
    let logger = XCGLogger.defaultInstance()

    var previousSize: NSRect?
    var currentSize: NSRect?
    var titleBarView: NSView?
    var controlUIView: ControlUIView?
    
    // default values
    var title: String = "mpx"
    var fullscreen = false
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.delegate = self
        
		AppDelegate.getInstance().playerWindowController = self
        titleBarView = self.window!.standardWindowButton(NSWindowButton.CloseButton)?.superview
        controlUIView = self.window!.contentView.subviews[1] as? ControlUIView
        
        // get default size
        currentSize = self.window?.frame
        
        center()
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if AppDelegate.getInstance().active {
            titleBarView!.animator().alphaValue = 1
            controlUIView!.animator().alphaValue = 1
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if !fullscreen {
            titleBarView!.animator().alphaValue = 0
        }
        controlUIView!.animator().alphaValue = 0
    }
    
    func resize(#width: Int, height: Int, fullscreen: Bool) {
        let screenFrame: NSRect
        if fullscreen {
            screenFrame = NSScreen.mainScreen()!.frame
        } else {
            screenFrame = NSScreen.mainScreen()!.visibleFrame
        }
        
        let size = NSSize(width: width, height: height)
        
        // cap new size to main screen resolution
        // while preserving the aspect ratio
        var h = CGFloat(size.height)
        var w = CGFloat(size.width)
        var ar = w / h
        
        var maxHeight = screenFrame.height
        
        if (h > maxHeight) {
            h = maxHeight
            w = h * ar
        }
        if (w > screenFrame.width) {
            w = screenFrame.width
            h = w / ar
        }
        
        // don't do anything if currentSize is the same
        if currentSize?.width == w && currentSize?.height == h {
            return
        }
        
        self.previousSize = self.window!.frame
        
        let xOffset = (screenFrame.width - w) / 2
        let yOffset = (screenFrame.height - h) / 2 + screenFrame.origin.y
        
        let frame = NSRect(x: xOffset, y: yOffset, width: w, height: h)
        
        // resize NSWindow with animation
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
    
    func windowWillEnterFullScreen(notification: NSNotification) {
        let screenSize = NSScreen.mainScreen()!.frame
        resize(width: Int(screenSize.width), height: Int(screenSize.height), fullscreen: true)
        self.fullscreen = true
    }
    
    func windowWillExitFullScreen(notification: NSNotification) {
        if self.previousSize != nil {
            resize(width: Int(self.previousSize!.width), height: Int(self.previousSize!.height), fullscreen: false)
        } else {
            // todo get video size
        }
        self.fullscreen = false
    }
    
    func windowWillClose(notification: NSNotification) {
        NSApplication.sharedApplication().stop(notification)
    }
}
