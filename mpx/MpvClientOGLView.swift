//
//  MpvClientOGLView.swift
//  mpx
//
//  Created by Jiening Wen on 02/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa
import OpenGL.GL
import XCGLogger

class MpvClientOGLView: NSOpenGLView {

	let logger = XCGLogger.defaultInstance()
	
	var mpvOGLContext: UnsafeMutablePointer<Void>?
    
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
    
    override var bounds: CGRect {
        didSet {
            self.updateTrackingAreas()
        }
    }
    
	required init?(coder: NSCoder) {
	    super.init(coder: coder)
		logger.debug("init with coder: \(coder.debugDescription)")

		configureOpenGLViewForMpv()
	}
	
	override init(frame frameRect: NSRect) {
		logger.debug("init with frame")
		super.init(frame: frameRect)
	}
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
		drawRect()
    }
    
    override func updateTrackingAreas() {
        for area in self.trackingAreas {
            if area is NSTrackingArea {
                removeTrackingArea(area as! NSTrackingArea)
            }
        }
        let area = NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.ActiveAlways, owner: self, userInfo: nil)
        logger.debug("add tracking area \(area.debugDescription)")
        addTrackingArea(area)
    }
        
	func drawRect() {
		if (mpvOGLContext == nil) {
			fillBlack()
		} else {
			//logger.debug("\(self.bounds.width)x\(self.bounds.height)")
			mpv_opengl_cb_draw(COpaquePointer(mpvOGLContext!), Int32(0), Int32(self.bounds.width), Int32(-self.bounds.height))
		}
		self.openGLContext.flushBuffer()
	}
	
	func configureOpenGLViewForMpv() {
		AppDelegate.getInstance().openGLView = self

		// swap on vsyncs
		self.openGLContext.setValues([GLint(1)], forParameter: NSOpenGLContextParameter.GLCPSwapInterval)
		self.openGLContext.makeCurrentContext()
	}
	
	func fillBlack() {
		glClearColor(0, 0, 0, 0)
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
	}
	
}
