//
//  swiftbridge.h
//  mpx
//
//  Created by Jiening Wen on 01/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

#ifndef mpx_swiftbridge_h
#define mpx_swiftbridge_h

#import <Foundation/Foundation.h>
#import "client.h"

// helper functions
NSDictionary* get_mpv_node_list_as_dict(mpv_node node);

void mpv_cmd_node_async(mpv_handle *context, NSArray *values, mpv_format *mpv_formats);

#endif
