//
//  PlayerState.swift
//  mpx
//
//  Created by Jiening Wen on 24/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

import Cocoa

enum PlayerState {
    case Uninitialized
    case Initialized
    case Idle
    case FileLoaded
    case Playing
    case Paused
    case Stopped
    case EndOfFile
}
