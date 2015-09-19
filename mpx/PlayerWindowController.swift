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

    weak var mpv: MpvController?
    var defaultFrame: NSRect?
    var previousFrame: NSRect?
        
    // default values
    var title: String = "mpx"    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.delegate = self
        defaultFrame = window?.frame
        
        center()
    }
        
    override func mouseDown(event: NSEvent) {
        // double click toggles fullscreen
        if event.clickCount == 2 && AppDelegate.getInstance().mediaFileLoaded {
            window?.toggleFullScreen(self)
        }
    }
	
	override func keyDown(event: NSEvent) {
		switch event.keyCode {
		case KeyCode.kVK_Space.UInt16Value():
			mpv!.togglePause()
			
		case KeyCode.kVK_LeftArrow.UInt16Value():
			mpv!.seekBySecond(-5)
			
		case KeyCode.kVK_RightArrow.UInt16Value():
			mpv!.seekBySecond(5)
		
		case KeyCode.kVK_UpArrow.UInt16Value():
			mpv!.seekBySecond(60)

		case KeyCode.kVK_DownArrow.UInt16Value():
			mpv!.seekBySecond(-60)

		default:
			logger.debug("keycode: \(event.keyCode)")
		}
	}
    
	func hideWindow() {
        dispatch_async(dispatch_get_main_queue(), {
            window?.orderOut(self)
        })
    }
    
    func showWindow() {
        dispatch_async(dispatch_get_main_queue(), {
            self.showWindow(self)
        })
    }
    
    func resize(width width: CGFloat, height: CGFloat) {
        let screenFrame = NSScreen.mainScreen()!.visibleFrame
        
        let size = NSSize(width: width, height: height)
        
        // cap new size to main screen resolution
        // while preserving the aspect ratio
        var h = size.height
        var w = size.width
        let ar = w / h
        
        let maxHeight = screenFrame.height
        
        if (h > maxHeight) {
            h = maxHeight
            w = h * ar
        }
        if (w > screenFrame.width) {
            w = screenFrame.width
            h = w / ar
        }
        
        // don't do anything if currentSize is the same
        let currentFrame = window?.frame
        if currentFrame?.width == w && currentFrame?.height == h {
            return
        }
        
        let xOffset = (screenFrame.width - w) / 2
        let yOffset = (screenFrame.height - h) / 2 + screenFrame.origin.y
        
        let frame = NSRect(x: xOffset, y: yOffset, width: w, height: h)
        
        // resize NSWindow with animation
        dispatch_async(dispatch_get_main_queue(), {
            self.window?.setFrame(frame, display: true, animate: false)
        })
        
        previousFrame = currentFrame
    }
    
    func center() {
        let visibleFrame = NSScreen.mainScreen()?.visibleFrame
        let currentFrame = self.window!.frame
        let x = (visibleFrame!.width - currentFrame.width) / 2
        let y = (visibleFrame!.height - currentFrame.height) / 2 + visibleFrame!.origin.y
        window?.setFrameOrigin(NSPoint(x: x, y: y))
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
    
    func customWindowsToEnterFullScreenForWindow(window: NSWindow) -> [NSWindow]? {
        return [window]
    }
    
    func window(window: NSWindow, startCustomAnimationToEnterFullScreenWithDuration duration: NSTimeInterval) {
        let currentFrame = window.frame
        let screenFrame = NSScreen.mainScreen()!.frame
        
        var frame = currentFrame
        frame.origin.x = (screenFrame.width - currentFrame.width) / 2
        frame.origin.y = (screenFrame.height - currentFrame.height) / 2
        
        // custom fullscreen animation
        // center than resize
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) -> Void in
            context.duration = duration
            window.animator().setFrame(frame, display: true)
        }, completionHandler: { () -> Void in
           window.setFrame(NSScreen.mainScreen()!.frame, display: true)
        })
        
        // only remember previous window size if playback has started
        if mpv!.state == .Playing || mpv!.state == .Paused {
            previousFrame = currentFrame
        }
    }
    
    func customWindowsToExitFullScreenForWindow(window: NSWindow) -> [NSWindow]? {
        return [window]
    }
    
    func window(window: NSWindow, startCustomAnimationToExitFullScreenWithDuration duration: NSTimeInterval) {
        // disable window resize animation
        if mpv!.state == .Playing || mpv!.state == .Paused {
            if previousFrame != nil {
                window.setFrame(previousFrame!, display: true)
            } else if let originalSize = AppDelegate.getInstance().mpv!.videoOriginalSize {
                resize(width: originalSize.width, height: originalSize.height)
            } else {
                window.setFrame(defaultFrame!, display: true)
            }
        } else {
            window.setFrame(defaultFrame!, display: true)
        }
    }
    
    func windowDidEnterFullScreen(notification: NSNotification) {
        AppDelegate.getInstance().fullscreen = true
    }
    
    func windowDidExitFullScreen(notification: NSNotification) {
        AppDelegate.getInstance().fullscreen = false
    }
    
    func windowWillClose(notification: NSNotification) {
        NSApplication.sharedApplication().stop(self)
    }
    
    func updateTitle(title: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.willChangeValueForKey("title")
            self.title = title
            self.didChangeValueForKey("title")
        })
    }
    
    func resizeHalf() {
        let originalSize = mpv!.videoOriginalSize!
        resize(width: originalSize.width / 2, height: originalSize.height / 2)
    }
    
    func resizeOriginal() {
        let originalSize = mpv!.videoOriginalSize!
        resize(width: originalSize.width, height: originalSize.height)
    }
    
    func resizeDouble() {
        let originalSize = mpv!.videoOriginalSize!
        resize(width: originalSize.width * 2, height: originalSize.height * 2)
    }
}
