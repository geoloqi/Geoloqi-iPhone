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
	
    // __dbhan: Change this to go to the High res mode or the UDP mode .... needs a function probably....
    // __dbhan: algorithm: set the send mode to udp
    if (0) 
    {
        NSUserDefaults *defaults;
        [[Geoloqi sharedInstance] setSendingMethodTo:LQSendingMethodUDP]; //__dbhan ;; This set the shared library variable ...
        [defaults setObject:@"NO" forKey:LQLocationUpdateManagerSendingMethodDefaultKey]; // __dbhan: NO = OFF = HTTP ;; YES = ON = UDP
        // __dbhan: Now set the setting to high res mode ;; The settings need to be distance_filter = 1m; tracking_limit = 1s ;; rate_limit = 0s
        [defaults setFloat:1 forKey:@"hiresDistanceFilter"];
        [defaults setFloat:1 forKey:@"hiresTrackingLimit"];
        [defaults setFloat:0 forKey:@"hiresRateLimit"];
        [defaults synchronize];
        NSLog(@"Hi-Res defaults saved");
    }
    
	// __dbhan: Once the hi-res values have been set then retrieve the values again to be used for data send
    NSLog(@"Setting to high res mode");
	df = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresDistanceFilter"] floatValue];
	tl = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresTrackingLimit"] floatValue];
	rl = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresRateLimit"] floatValue];
	
	[[Geoloqi sharedInstance] setDistanceFilterTo:df];
	[[Geoloqi sharedInstance] setTrackingFrequencyTo:tl];
	[[Geoloqi sharedInstance] setSendingFrequencyTo:rl];
	/* * */

	// Start the tracker
	[[Geoloqi sharedInstance] startLocationUpdates]; // __dbhan: Since we are in the hi-res mode .. we need to use startLocationUpdates to start using the GPS based location points

// __dbhan: We do not need to use notification as when the link expires, we either go to the HTTP(Passive/battery safe mode) of to the custom mode.
// __dbhan: If the user shuts off the app, the user anyway does not need to know that the tracking has been turned off. At this time it is a don't care
/*
	// Create a notification that will prompt the user to turn off tracking after the elapsed time
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	// TODO: This is from Apple's sample code. When would this not be set?
	if (notification == nil)
		return;
//__dbhan/__aaronpk: ORIGINAL_NOTES from our discussion drop the notification and put it back into the passive mode 
//                   or the cutome mode whichever state it was in  and get rid of the notification and cancellation ... 
	notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"Shared Link Expired", @"title",
							 @"The shared link expired. Would you like to turn tracking off?", @"description",
							 @"shutdownPrompt", @"type",
							 nil];
	notification.alertBody = @"The shared link expired. Would you like to turn tracking off?";
	notification.alertAction = @"Yes";
	notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:[_minutes intValue] * 60];
	
	// Schedule the notification
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];

	// Add the notification to the list of current notifications so they can be cancelled when needed
	NSLog(@"Adding notification to the list");
	[[Geoloqi sharedInstance] addShutdownTimer:notification];
	[notification release];
*/
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

- (void)shareControllerDidFinish:(UIViewController *)_controller {
	[[Geoloqi sharedInstance] startLocationUpdates];
	[_controller dismissModalViewControllerAnimated:YES];
}

- (void)shareControllerDidCancel:(UIViewController *)_controller {
	[_controller dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[controller dealloc];
	[super dealloc];
}

@end
