//
//  swiftbridge.m
//  mpx
//
//  Created by Jiening Wen on 02/08/15.
//  Copyright (c) 2015 phill84. All rights reserved.
//

#import <mpx-Swift.h>
#import "swiftbridge.h"

static void *get_proc_address(void *ctx, const char *name)
{
	CFStringRef symbolName = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII);
	void *addr = CFBundleGetFunctionPointerForName(CFBundleGetBundleWithIdentifier(CFSTR("com.apple.opengl")), symbolName);
	CFRelease(symbolName);
	return addr;
}

mpv_opengl_cb_get_proc_address_fn get_proc_address_fn()
{
	return get_proc_address;
}

static void glupdate(void *ctx)
{
	MpvController *player = (__bridge MpvController *)ctx;
	// I'm still not sure what the best way to handle this is, but this works.
	dispatch_async(dispatch_get_main_queue(), ^{
		[player drawRect];
	});
}

mpv_opengl_cb_update_fn get_update_fn()
{
	return glupdate;
}

NSDictionary* get_mpv_node_list_as_dict(mpv_node node) {
	if (node.format != MPV_FORMAT_NODE_ARRAY && node.format != MPV_FORMAT_NODE_MAP) {
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
