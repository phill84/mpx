//
//  ControlView.swift
//  mpx
//
//  Created by Jiening Wen on 21/08/15.
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

class ControlView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        self.superview!.layer!.cornerRadius = 5
        self.superview!.layer!.masksToBounds = true
        self.superview!.layer!.edgeAntialiasingMask = [CAEdgeAntialiasingMask.LayerBottomEdge, CAEdgeAntialiasingMask.LayerLeftEdge, CAEdgeAntialiasingMask.LayerRightEdge, CAEdgeAntialiasingMask.LayerTopEdge]
        
        super.drawRect(dirtyRect)
    }
}