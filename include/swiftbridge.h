//
//  swiftbridge.h
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
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

#ifndef mpx_swiftbridge_h
#define mpx_swiftbridge_h

#import <Foundation/Foundation.h>
#import "client.h"

// helper functions
NSDictionary* get_mpv_node_list_as_dict(mpv_node node);

void mpv_cmd_node_async(mpv_handle *context, NSArray *values, mpv_format *mpv_formats);

#endif
