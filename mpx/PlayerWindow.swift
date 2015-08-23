//
//  PlayerWindow.swift
//  mpx
//
//  Created by Jiening Wen on 20/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class PlayerWindow: NSWindow {

    let logger = XCGLogger.defaultInstance()
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        self.backgroundColor = NSColor.blackColor()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func sendEvent(event: NSEvent) {
        // do not send events to video view
        if !(firstResponder is VideoView) {
            super.sendEvent(event)
        }
    }
}
