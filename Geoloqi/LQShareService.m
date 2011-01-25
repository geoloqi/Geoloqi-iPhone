//
//  LQShareService.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareService.h"
#import "Geoloqi.h"

@implementation LQShareService

@synthesize controller;

+ (void)linkWasSent:(NSString *)verb {
	NSString *msg = @"You are now sharing your location!";
	
	if(![[Geoloqi sharedInstance] locationUpdatesState]) {
		msg = [NSString stringWithFormat:@"%@ Tracking has been turned on. Turn off tracking when you stop moving to save battery.", msg];
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:verb
													message:msg
												   delegate:nil
										  cancelButtonTitle:@"Close"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];

	/* Set the tracker into hi-res mode */
	CGFloat df, tl, rl;
	
	NSLog(@"Setting to high res mode");
	df = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresDistanceFilter"] floatValue];
	tl = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresTrackingLimit"] floatValue];
	rl = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresRateLimit"] floatValue];
	
	[[Geoloqi sharedInstance] setDistanceFilterTo:df];
	[[Geoloqi sharedInstance] setTrackingFrequencyTo:tl];
	[[Geoloqi sharedInstance] setSendingFrequencyTo:rl];
	/* * */
	
	[[Geoloqi sharedInstance] startLocationUpdates];
}

- (LQShareService *)initWithController:(UIViewController *)_controller {
    if (self = [super init]) {
		self.controller = _controller;
    }
    return self;
}

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message {
	NSLog(@"!!!! Implement this method in the child class to perform the appropriate share function.");
}

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message canPost:(BOOL)canPost {
	NSLog(@"!!!! Implement this method in the child class to perform the appropriate share function.");
}

- (void)presentModalViewController:(UIViewController *)_controller {
	[self.controller presentModalViewController:_controller animated:YES];
}

- (void)shareControllerDidFinish {
	[[Geoloqi sharedInstance] startLocationUpdates];
	[self.controller.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)shareControllerDidCancel:(UIViewController *)_controller {
	[_controller dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[controller dealloc];
	[super dealloc];
}

@end
