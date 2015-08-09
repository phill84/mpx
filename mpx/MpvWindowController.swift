//
//  MpvWindowController.swift
//  mpx
//
//  Created by Jiening Wen on 08/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa

class MpvWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
		AppDelegate.getInstance().mpvWindow = self
    }

}
