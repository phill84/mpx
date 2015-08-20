//
//  PlayerView.swift
//  mpx
//
//  Created by Jiening Wen on 16/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class PlayerView: NSView {

    let logger = XCGLogger.defaultInstance()
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func didAddSubview(subview: NSView) {
        logger.debug(subview.debugDescription)
//        if !(subview is ControlUIView) {
//            let controlUIView = self.subviews[0] as! ControlUIView
//            let mpvEventsView = self.subviews[1] as! NSView
//            dispatch_async(dispatch_get_main_queue(), {
//                controlUIView.removeFromSuperviewWithoutNeedingDisplay()
//                self.addSubview(controlUIView, positioned: NSWindowOrderingMode.Above, relativeTo: mpvEventsView)
//            })
//        }
    }
    
}
