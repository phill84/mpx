//
//  swiftbridge.m
//  mpx
//
//  Created by Jiening Wen on 02/08/15.
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

#import <mpx-Swift.h>
#import "swiftbridge.h"

NSDictionary* get_mpv_node_list_as_dict(mpv_node node) {
	if (node.format != MPV_FORMAT_NODE_MAP) {
		return nil;
	}
	
	mpv_node_list list = *node.u.list;
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity: list.num];
	
	for (int i = 0; i < list.num; i ++) {
		NSString *key = [NSString stringWithUTF8String: list.keys[i]];
		mpv_node node = list.values[i];
		
		switch (node.format) {
			case MPV_FORMAT_NONE: {
				break;
			}
			case MPV_FORMAT_BYTE_ARRAY: {
				break;
			}
			case MPV_FORMAT_NODE: {
				break;
			}
			case MPV_FORMAT_INT64: {
				int64_t value = node.u.int64;
				[dict setObject: @(value) forKey: key];
				break;
			}
			case MPV_FORMAT_DOUBLE: {
				double value = node.u.double_;
				[dict setObject: @(value) forKey: key];
				break;
			}
			case MPV_FORMAT_FLAG: {
				int value = node.u.flag;
				[dict setObject: @(value) forKey: key];
				break;
			}
			case MPV_FORMAT_STRING:
			case MPV_FORMAT_OSD_STRING: {
				char* value = node.u.string;
				[dict setObject: [NSString stringWithUTF8String: value] forKey: key];
				break;
			}
			case MPV_FORMAT_NODE_ARRAY:
			case MPV_FORMAT_NODE_MAP: {
				mpv_node_list list = *node.u.list;
				[dict setObject: [NSValue value: &list withObjCType: [@"mpv_node_list" cStringUsingEncoding: NSUTF8StringEncoding]] forKey: key];
				break;
			}
		}
		
		
	}
	
	return dict;
}

void mpv_cmd_node_async(mpv_handle *context, NSArray *values, mpv_format *mpv_formats) {
	mpv_node items[values.count];
	mpv_node_list list = {.values = items};
	mpv_node node = {
		.format = MPV_FORMAT_NODE_ARRAY,
		.u = {
			.list = &list
		}
	};
	
	for (int i=0; i<[values count]; i++) {
		switch (mpv_formats[i]) {
			case MPV_FORMAT_STRING: {
				const char* utf8String = [(NSString *)[values objectAtIndex: i] UTF8String];

				size_t len = strlen(utf8String) + 1;
				char *string = malloc(len);
				memcpy(string, utf8String, len);
				
				items[list.num++] = (mpv_node) {
					.format = MPV_FORMAT_STRING,
					.u = {.string = string}
				};
				break;
			}
			case MPV_FORMAT_INT64: {
				int64_t value = [(NSNumber *)[values objectAtIndex: i] intValue];
				items[list.num++] = (mpv_node) {
					.format = MPV_FORMAT_INT64,
					.u = {.int64 = value}
				};
				break;
			}
			default:
				break;
		}
	};
	
	mpv_command_node_async(context, 0, &node);
}
