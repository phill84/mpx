//
//  MpxUIWindowController.swift
//  mpx
//
//  Created by Jiening Wen on 11/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import AppKit
import Cocoa
import XCGLogger

class MpxUIWindowController: NSWindowController {
    
    let logger = XCGLogger.defaultInstance()
    
    var uiView: MpxUIView?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        uiView = self.window?.contentView as? MpxUIView
    }
    
    func fadeIn() {
        NSAnimationContext.beginGrouping()
        uiView?.animator().alphaValue = 1.0
        NSAnimationContext.endGrouping()
    }
    
    func fadeOut() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0.01
        uiView?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
    
    func cancelFadeOut() {

    }

}
