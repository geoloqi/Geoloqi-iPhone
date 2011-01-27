//
//  LQShareTwitter.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareTwitter.h"
#import "LQShareTwitterViewController.h"
#import "LQShareTwitterConnectViewController.h"

@implementation LQShareTwitter

@synthesize shareView;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes canPost:(BOOL)canPost {
	self.minutes = _minutes;
	if(canPost) {
		NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];
		self.shareView = [[LQShareTwitterViewController alloc] initWithMessage:body];
		self.shareView.delegate = self;
		[self presentModalViewController:shareView];
	} else {
		LQShareTwitterConnectViewController *twitterConnectController = [[LQShareTwitterConnectViewController alloc] init];
		[self presentModalViewController:twitterConnectController];
		[twitterConnectController release];
	}
}

- (void)twitterDidFinish {
	[LQShareService linkWasSent:@"Posted to Twitter" minutes:self.minutes];
	[self shareControllerDidFinish];
}

- (void)twitterDidCancel {
	[self shareControllerDidCancel:shareView];
}

- (void)dealloc {
	[shareView dealloc];
	[super dealloc];
}

@end
