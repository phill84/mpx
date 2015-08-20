//
//  ControlUIView.swift
//  mpx
//
//  Created by Jiening Wen on 11/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class ControlUIView: NSView {

    let logger = XCGLogger.defaultInstance()
    
    override var bounds: CGRect {
        didSet {
            self.updateTrackingAreas()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        AppDelegate.getInstance().playerWindowController?.uiView = self
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func updateTrackingAreas() {
        for area in self.trackingAreas {
            if area is NSTrackingArea {
                removeTrackingArea(area as! NSTrackingArea)
            }
        }
        let area = NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways, owner: self, userInfo: nil)
        addTrackingArea(area)
        
        super.updateTrackingAreas()
    }

    
}