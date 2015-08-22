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
    
    override func sendEvent(event: NSEvent) {
        // do not send events to video view
        if !(firstResponder is VideoView) {
            super.sendEvent(event)
        }
    }
}
