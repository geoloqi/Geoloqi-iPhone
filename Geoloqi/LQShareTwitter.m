//
//  LQShareTwitter.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareTwitter.h"
#import "LQShareTwitterViewController.h"

@implementation LQShareTwitter

@synthesize shareView;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message {
	NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];
	self.shareView = [[LQShareTwitterViewController alloc] initWithMessage:body];
	self.shareView.delegate = self;
	[self presentModalViewController:shareView];
}

- (void)twitterDidFinish {
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
