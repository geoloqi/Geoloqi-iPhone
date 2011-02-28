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
@synthesize minutes;

+ (void)linkWasSent:(NSString *)verb minutes:(NSNumber *)_minutes {
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

	
	// Start the tracker
	[[Geoloqi sharedInstance] startLocationUpdates];

	
	// Create a notification that will prompt the user to turn off tracking after the elapsed time
	
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	// TODO: This is from Apple's sample code. When would this not be set?
	if (notification == nil)
		return;
	
	notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Shared Link Expired", @"title",
							 @"The shared link expired. Would you like to turn tracking off?", @"description",
							 @"shutdownPrompt", @"type",
							 nil];
	notification.alertBody = @"The shared link expired. Would you like to turn tracking off?";
	notification.alertAction = @"Yes";
	notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:[_minutes intValue] ]; // * 60];
	
	// Schedule the notification
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];

	// Add the notification to the list of current notifications so they can be cancelled when needed
	NSLog(@"Adding notification to the list");
	[[Geoloqi sharedInstance] addShutdownTimer:notification];

	[notification release];
}

- (LQShareService *)initWithController:(UIViewController *)_controller {
    if (self = [super init]) {
		self.controller = _controller;
    }
    return self;
}

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes {
	NSLog(@"!!!! Implement this method in the child class to perform the appropriate share function.");
}

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes canPost:(BOOL)canPost {
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
