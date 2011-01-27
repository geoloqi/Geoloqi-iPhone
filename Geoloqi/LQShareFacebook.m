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
		self.shareView = [[LQShareFacebookViewController alloc] initWithMessage:message andURL:[url absoluteString]];
		self.shareView.delegate = self;
		[self presentModalViewController:shareView];
	} else {
		LQShareFacebookConnectViewController *facebookConnectController = [[LQShareFacebookConnectViewController alloc] init];
		[self presentModalViewController:facebookConnectController];
		[facebookConnectController release];
	}
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
