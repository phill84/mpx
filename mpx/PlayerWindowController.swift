//
//  PlayerWindowController.swift
//  mpx
//
//  Created by Jiening Wen on 08/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class PlayerWindowController: NSWindowController, NSWindowDelegate {
    
    let logger = XCGLogger.defaultInstance()
    let idleInterval = NSTimeInterval(2) // 2 seconds

    var previousFrame: NSRect?
    var titleBarView: NSView?
    var controlUIView: ControlUIView?
    var idleTimer: NSTimer?
    
    // default values
    var title: String = "mpx"
    var fullscreen = false
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.delegate = self
        
		AppDelegate.getInstance().playerWindowController = self
        titleBarView = self.window!.standardWindowButton(NSWindowButton.CloseButton)?.superview
        controlUIView = self.window!.contentView.subviews[1] as? ControlUIView
        
        center()
        resetIdleTimer()
    }
    
    override func mouseEntered(event: NSEvent) {
        showControlUI()
    }
    
    override func mouseExited(event: NSEvent) {
        hideControlUI()
    }
    
    override func mouseMoved(event: NSEvent) {
        showControlUI()
    }
    
    override func mouseDown(event: NSEvent) {
        // double click toggles fullscreen
        if event.clickCount == 2 {
            self.window?.toggleFullScreen(self)
        }
    }
    
    func showControlUI() {
        if AppDelegate.getInstance().active {
            resetIdleTimer()
            titleBarView!.animator().alphaValue = 1
            controlUIView!.animator().alphaValue = 1
        }
    }
    
    func hideControlUI() {
        // invalidate idleTimer since controlUI will be hidden already
        self.idleTimer?.invalidate()
        if !fullscreen {
            titleBarView!.animator().alphaValue = 0
        }
        controlUIView!.animator().alphaValue = 0
    }
    
    func resize(#width: Int, height: Int) {
        let screenFrame = NSScreen.mainScreen()!.visibleFrame
        
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
        let currentFrame = self.window?.frame
        if currentFrame?.width == w && currentFrame?.height == h {
            return
        }
        
        let xOffset = (screenFrame.width - w) / 2
        let yOffset = (screenFrame.height - h) / 2 + screenFrame.origin.y
        
        let frame = NSRect(x: xOffset, y: yOffset, width: w, height: h)
        
        // resize NSWindow with animation
        dispatch_async(dispatch_get_main_queue(), {
            self.window?.setFrame(frame, display: true, animate: true)
        })
        
        self.previousFrame = currentFrame
    }
    
    func center() {
        let visibleFrame = NSScreen.mainScreen()?.visibleFrame
        let currentFrame = self.window!.frame
        let x = (visibleFrame!.width - currentFrame.width) / 2
        let y = (visibleFrame!.height - currentFrame.height) / 2 + visibleFrame!.origin.y
        self.window!.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    func alertAndExit(error: String) {
        let alert = NSAlert()
        alert.addButtonWithTitle("OK")
        alert.messageText = "Failed to initialize mpv"
        alert.informativeText = error
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        if alert.runModal() == NSAlertFirstButtonReturn {
            NSApplication.sharedApplication().terminate(self)
        }
    }
    
    func customWindowsToEnterFullScreenForWindow(window: NSWindow) -> [AnyObject]? {
        return [window]
    }
    
    func window(window: NSWindow, startCustomAnimationToEnterFullScreenWithDuration duration: NSTimeInterval) {
        let currentFrame = self.window!.frame
        let screenFrame = NSScreen.mainScreen()!.frame
        
        var frame = currentFrame
        frame.origin.x = (screenFrame.width - currentFrame.width) / 2
        frame.origin.y = (screenFrame.height - currentFrame.height) / 2
        
        // custom fullscreen animation
        // center than resize
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            context.duration = duration
            window.animator().setFrame(frame, display: true)
        }, completionHandler: { () -> Void in
           window.setFrame(NSScreen.mainScreen()!.frame, display: true)
        })
        
        self.previousFrame = currentFrame
    }
    
    func customWindowsToExitFullScreenForWindow(window: NSWindow) -> [AnyObject]? {
        return [window]
    }
    
    func window(window: NSWindow, startCustomAnimationToExitFullScreenWithDuration duration: NSTimeInterval) {
        // disable window resize animation
        if previousFrame != nil {
            window.setFrame(previousFrame!, display: true)
        }
    }
    
    func windowDidEnterFullScreen(notification: NSNotification) {
        self.fullscreen = true
    }
    
    func windowDidExitFullScreen(notification: NSNotification) {
        self.fullscreen = false
    }
    
    func windowWillClose(notification: NSNotification) {
        NSApplication.sharedApplication().stop(self)
    }
    
    func resetIdleTimer() {
        self.idleTimer?.invalidate()
        self.idleTimer = NSTimer(timeInterval: self.idleInterval, target: self, selector: Selector("hideControlUI"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.idleTimer!, forMode: NSDefaultRunLoopMode)
    }
}
