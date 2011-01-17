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

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message canPost:(BOOL)canPost {
	if(canPost) {
		NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];
		self.shareView = [[LQShareFacebookViewController alloc] initWithMessage:body];
		self.shareView.delegate = self;
		[self presentModalViewController:shareView];
	} else {
		LQShareFacebookConnectViewController *facebookConnectController = [[LQShareFacebookConnectViewController alloc] init];
		[self presentModalViewController:facebookConnectController];
		[facebookConnectController release];
	}
}

- (void)facebookDidFinish {
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
