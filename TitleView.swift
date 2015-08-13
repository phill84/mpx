//
//  TitleView.swift
//  mpx
//
//  Created by Jiening Wen on 09/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import XCGLogger

class TitleView: NSView {

	let logger = XCGLogger.defaultInstance()
    let bgcolor = NSColor(patternImage: NSImage(named: "titlebar-bg")!)
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
        AppDelegate.getInstance().playerWindowController?.titleView = self
	}
	
    override func drawRect(dirtyRect: NSRect) {
        bgcolor.setFill()
        NSRectFill(dirtyRect)
        super.drawRect(dirtyRect)
    }
	
}
