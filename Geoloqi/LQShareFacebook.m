/*
//
//  LQShareFacebook.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareFacebook.h"
#import "LQShareFacebookViewController.h"
#import "LQShareFacebookConnectViewController.h"

@implementation LQShareFacebook

@synthesize shareView;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes canPost:(BOOL)canPost {
	self.minutes = _minutes;
	if(canPost) {
		self.activityIndicator.alpha = 1.0f;
		self.sendButton.enabled = NO;
		
		// Try to post the update!
		[[Geoloqi sharedInstance] postToFacebook:self.textView.text
											 url:self.url
										callback:self.postedCallback];
	} else {
		LQShareFacebookConnectViewController *facebookConnectController = [[LQShareFacebookConnectViewController alloc] init];
		[self presentModalViewController:facebookConnectController];
		[facebookConnectController release];
	}
}


- (LQHTTPRequestCallback)postedCallback {
	if (postedCallback) return postedCallback;
	return postedCallback = [^(NSError *error, NSString *responseBody) {
		
		self.activityIndicator.alpha = 0.0f;
		self.sendButton.enabled = YES;
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		
		if (!res || [res objectForKey:@"error"] != nil) {
			[[SHKActivityIndicator currentIndicator] displayCompleted:@"Facebook Error!"];
			[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✕"];
			[self.delegate facebookDidCancel];
		}else{
			[[SHKActivityIndicator currentIndicator] displayCompleted:@"Posted!"];
			[self.delegate facebookDidFinish];
		}
	} copy];
}

- (void)facebookDidFinish {
	[LQShareService linkWasSent:@"Posted to Facebook" minutes:self.minutes];
	[self shareControllerDidFinish];
}

- (void)facebookDidCancel {
	[self shareControllerDidCancel:shareView];
}

- (void)dealloc {
	[shareView dealloc];
	[super dealloc];
}

@end
*/