//
//  ControlView.swift
//  mpx
//
//  Created by Jiening Wen on 21/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa

class ControlView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        self.superview!.layer!.cornerRadius = 5
        self.superview!.layer!.masksToBounds = true
        self.superview!.layer!.edgeAntialiasingMask = CAEdgeAntialiasingMask.LayerBottomEdge | CAEdgeAntialiasingMask.LayerLeftEdge | CAEdgeAntialiasingMask.LayerRightEdge | CAEdgeAntialiasingMask.LayerTopEdge
        
        super.drawRect(dirtyRect)
    }
}
