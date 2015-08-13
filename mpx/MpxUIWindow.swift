//
//  MpxUIWindow.swift
//  mpx
//
//  Created by Jiening Wen on 11/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa

class MpxUIWindow: NSWindow {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        self.backgroundColor = NSColor.clearColor()
        self.opaque = false
        
        self.ignoresMouseEvents = true
    }
}
