//
//  VideoView.swift
//  mpx
//
//  Created by Jiening Wen on 11/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class VideoView: NSView {

    let logger = XCGLogger.defaultInstance()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
}
