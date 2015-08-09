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
#import "opengl_cb.h"

// helper functions
mpv_opengl_cb_get_proc_address_fn get_proc_address_fn();
mpv_opengl_cb_update_fn get_update_fn();
NSDictionary* get_mpv_node_list_as_dict(mpv_node node);

#endif
