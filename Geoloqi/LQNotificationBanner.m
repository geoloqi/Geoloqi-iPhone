//
//  LQNotificationBanner.m
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQNotificationBanner.h"
#import "CJSONDeserializer.h"

@implementation LQNotificationBanner

@synthesize img, text, link;

- (id)init {
	self = [super init];
	
	self.img = nil;
	self.text = nil;
	self.link = nil;
	lastUpdated = nil;
	
	return self;
}

- (LQHTTPRequestCallback)callback {
	if (callback) return callback;
	return callback = [^(NSError *error, NSString *responseBody) {
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:NSUTF8StringEncoding]
																 error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for app banner) \"%@\": %@", responseBody, err);
			return;
		}

		if ([[res objectForKey:@"banner_img"] isKindOfClass:[NSString class]]) {
			self.img = [res objectForKey:@"banner_img"];
		} else {
			self.img = nil;
		}

		if ([[res objectForKey:@"banner_text"] isKindOfClass:[NSString class]]) {
			self.text = [res objectForKey:@"banner_text"];
		} else {
			self.text = nil;
		}

		if ([[res objectForKey:@"banner_link"] isKindOfClass:[NSString class]]) {
			self.link = [res objectForKey:@"banner_link"];
		} else {
			self.link = nil;
		}
		
		NSLog(@"New notification banner received %@", res);
		
		lastUpdated = [[NSDate alloc] init];
		
		loadedCallback(nil, nil);
		
		return;
	} copy];
}

- (void)refreshWithCallback:(LQHTTPRequestCallback)cb {
	loadedCallback = cb;
	// Cache the banner for 2 minutes
	if(lastUpdated == nil || [lastUpdated timeIntervalSinceNow] < -10) {
		[[Geoloqi sharedInstance] getBannerWithCallback:[self callback]];
	}
}

- (void)dealloc {
	[img release];
	[text release];
	[link release];
	[callback release];
	[super dealloc];
}

@end
