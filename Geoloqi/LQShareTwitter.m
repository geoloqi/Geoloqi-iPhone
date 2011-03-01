/*
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

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes canPost:(BOOL)canPost withCallback:(LQHTTPRequestCallback)callback {
	self.minutes = _minutes;
	if(canPost) {
		NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];

		self.activityIndicator.alpha = 1.0f;
		self.sendButton.enabled = NO;
		
		// Try to post the tweet!
		[[Geoloqi sharedInstance] postToTwitter:self.textView.text
									   callback:self.tweetPostedCallback];
	
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
*/