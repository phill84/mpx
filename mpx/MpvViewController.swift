//
//  ViewController.swift
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa

class MpvViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		AppDelegate.getInstance().mpvView = self
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}

}
