//
//  MpxTitleView.swift
//  mpx
//
//  Created by Jiening Wen on 09/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class MpxTitleView: NSView {

	let logger = XCGLogger.defaultInstance()
	let tbCornerLeft = NSImage(named: "titlebar-corner-left")
	let tbCornerRight = NSImage(named: "titlebar-corner-right")
	let tbMiddle = NSImage(named: "titlebar-middle")
    
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

		// draw left corner
		var drawPoint = NSPoint(x: 0, y: 0)
		tbCornerLeft!.drawAtPoint(drawPoint, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)
		
		// draw right
		drawPoint.x = self.frame.width - tbCornerRight!.size.width
		tbCornerRight!.drawAtPoint(drawPoint, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)
		
		// draw middle
		var middleRect = NSRect(origin: NSPoint(x: 0, y: 0), size: tbMiddle!.size)
		tbMiddle!.drawInRect(NSRect(x: tbCornerLeft!.size.width, y: 0, width: self.frame.size.width - tbCornerLeft!.size.width - tbCornerRight!.size.width, height: self.frame.size.height),
			fromRect: middleRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)
    }
	
}
