//
//  LQNotificationBanner.m
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQNotificationBanner.h"
#import "CJSONDeserializer.h"
#import "PKHTTPCachedImage.h"

@implementation LQNotificationBanner

@synthesize img, text, link, lastLocation;
@synthesize imageView, textLabel;

- (id)init {
	self = [super init];
	
	self.img = nil;
	self.text = nil;
	self.link = nil;
	lastUpdated = nil;
	self.lastLocation = nil;
	
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
		
		lastUpdated = [[NSDate alloc] init];

		if(self.img != nil) {
			[[PKHTTPCachedImage sharedInstance] setImageForView:self.imageView withURL:self.img];
			self.imageView.hidden = NO;
			self.textLabel.hidden = YES;
			self.hidden = NO;
		} else if(self.text != nil) {
			self.textLabel.text = self.text;
			self.imageView.hidden = YES;
			self.textLabel.hidden = NO;
			self.hidden = NO;
		} else {
			self.hidden = YES;
		}
		
		return;
	} copy];
}

- (void)refreshForLocation:(CLLocation *)location {
	// Cache the banner for 2 minutes
	if(location != NULL) {
		if(self.lastLocation == nil || lastUpdated == nil || [lastUpdated timeIntervalSinceNow] < -120) {
			[[Geoloqi sharedInstance] getBannerForLocation:location withCallback:[self callback]];
			NSLog(@"Getting new banner");
		}
		self.lastLocation = location;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// Called when the user taps the banner, text or image
	if(self.link != nil){
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.link]]];
	}
}


- (void)dealloc {
	[img release];
	[text release];
	[link release];
	[callback release];
	[lastUpdated release];
	[lastLocation release];
	[super dealloc];
}

@end
