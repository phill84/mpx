//
//  KeyCode.swift
//  mpx
//
//  Created by Jiening Wen on 05/09/15.
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

import Foundation


// the list of keycode is extracted from Carbon HIToolbox/Events.h
enum KeyCode: Int {
	/* keycodes for keys that are independent of keyboard layout*/
	case kVK_Return                    = 0x24
	case kVK_Tab                       = 0x30
	case kVK_Space                     = 0x31
	case kVK_Delete                    = 0x33
	case kVK_Escape                    = 0x35
	case kVK_Command                   = 0x37
	case kVK_Shift                     = 0x38
	case kVK_CapsLock                  = 0x39
	case kVK_Option                    = 0x3A
	case kVK_Control                   = 0x3B
	case kVK_RightShift                = 0x3C
	case kVK_RightOption               = 0x3D
	case kVK_RightControl              = 0x3E
	case kVK_Function                  = 0x3F
	case kVK_F17                       = 0x40
	case kVK_VolumeUp                  = 0x48
	case kVK_VolumeDown                = 0x49
	case kVK_Mute                      = 0x4A
	case kVK_F18                       = 0x4F
	case kVK_F19                       = 0x50
	case kVK_F20                       = 0x5A
	case kVK_F5                        = 0x60
	case kVK_F6                        = 0x61
	case kVK_F7                        = 0x62
	case kVK_F3                        = 0x63
	case kVK_F8                        = 0x64
	case kVK_F9                        = 0x65
	case kVK_F11                       = 0x67
	case kVK_F13                       = 0x69
	case kVK_F16                       = 0x6A
	case kVK_F14                       = 0x6B
	case kVK_F10                       = 0x6D
	case kVK_F12                       = 0x6F
	case kVK_F15                       = 0x71
	case kVK_Help                      = 0x72
	case kVK_Home                      = 0x73
	case kVK_PageUp                    = 0x74
	case kVK_ForwardDelete             = 0x75
	case kVK_F4                        = 0x76
	case kVK_End                       = 0x77
	case kVK_F2                        = 0x78
	case kVK_PageDown                  = 0x79
	case kVK_F1                        = 0x7A
	case kVK_LeftArrow                 = 0x7B
	case kVK_RightArrow                = 0x7C
	case kVK_DownArrow                 = 0x7D
	case kVK_UpArrow                   = 0x7E
	
	func UInt16Value() -> UInt16 {
		return UInt16(rawValue)
	}
}