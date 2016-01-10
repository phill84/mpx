//
//  PlayerWindowController.swift
//  mpx
//
//  Created by Jiening Wen on 08/08/15.
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
            self.window?.orderOut(self)
        })
    }
    
    func showWindow() {
        dispatch_async(dispatch_get_main_queue(), {
            self.showWindow(self)
        })
    }
    
	func resize(videoWidth width: CGFloat, videoHeight height: CGFloat, inRect frame: NSRect) {
        
        let size = NSSize(width: width, height: height)
        
        // cap new size to main screen resolution
        // while preserving the aspect ratio
        var h = size.height
        var w = size.width
        let ar = w / h
        
        let maxHeight = frame.height
        
        if (h > maxHeight) {
            h = maxHeight
            w = h * ar
        }
        if (w > frame.width) {
            w = frame.width
            h = w / ar
        }
        
        // don't do anything if currentSize is the same
        let currentFrame = window?.frame
        if currentFrame?.width == w && currentFrame?.height == h {
            return
        }
        
        let xOffset = (frame.width - w) / 2
        let yOffset = (frame.height - h) / 2 + frame.origin.y
        
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
				resize(videoWidth: originalSize.width, videoHeight: originalSize.height, inRect: NSScreen.mainScreen()!.visibleFrame)
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
        resize(videoWidth: originalSize.width / 2, videoHeight: originalSize.height / 2, inRect: NSScreen.mainScreen()!.visibleFrame)
    }
    
    func resizeOriginal() {
        let originalSize = mpv!.videoOriginalSize!
        resize(videoWidth: originalSize.width, videoHeight: originalSize.height, inRect: NSScreen.mainScreen()!.visibleFrame)
    }
    
    func resizeDouble() {
        let originalSize = mpv!.videoOriginalSize!
        resize(videoWidth: originalSize.width * 2, videoHeight: originalSize.height * 2, inRect: NSScreen.mainScreen()!.visibleFrame)
    }
}
