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

	//__dbhan: How will this function change ..
    /* Set the tracker into hi-res mode */
	CGFloat df, tl, rl;
	
	// __dbhan: The hi-res values set in LQShareViewController.m are retrieved here and the values again to be used for data send
    // __dbhan: The distance filter, rate limit and the tracking limit are set to hires as after sending the link the app goes 
    // __dbhan: UDP/HIRES mode
    // __dbhan: This is not a good place to get the pre trip start mode
	df = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresDistanceFilter"] floatValue];
	tl = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresTrackingLimit"] floatValue];
	rl = [[[NSUserDefaults standardUserDefaults] stringForKey:@"hiresRateLimit"] floatValue];
	
	[[Geoloqi sharedInstance] setDistanceFilterTo:df];
	[[Geoloqi sharedInstance] setTrackingFrequencyTo:tl];
	[[Geoloqi sharedInstance] setSendingFrequencyTo:rl];
	/* * */

	// and then start the tracker
	[[Geoloqi sharedInstance] startLocationUpdates]; // __dbhan: Since we are in the hi-res mode .. we need to use startLocationUpdates to start using the GPS based location points

// __dbhan: We do not need to use notification as when the link expires, we either go to the HTTP(Passive/battery safe mode) of to the custom mode.
// __dbhan: If the user shuts off the app, the user anyway does not need to know that the tracking has been turned off. At this time it is a don't care
//__dbhan/__aaronpk: ORIGINAL_NOTES from our discussion drop the notification and put it back into the passive mode 
//__dbhan/__aaronpk: or the custom mode whichever state it was in  and get rid of the notification and cancellation ... 
//__dbhan: So we add a notification to see when the timer expires and then get a notification which calls a function to then take further actions ..
/*	// Create a notification that will prompt the user to turn off tracking after the elapsed time
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
	notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:[_minutes intValue] * 60];
	// Schedule the notification
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	// Add the notification to the list of current notifications so they can be cancelled when needed
	NSLog(@"Adding notification to the list");
	[[Geoloqi sharedInstance] addShutdownTimer:notification];
	[notification release]; 
 */
    /*__dbhan: I need to store:
     1. Current mode: HTTP/UDP
     2. Distance filter
     3. Tracking Limit
     4. Rate Limit
    */
    //[NSTimer scheduledTimerWithTimeInterval:[_minutes intValue]*60
    [NSTimer scheduledTimerWithTimeInterval:([_minutes intValue]*60) / 12
                                     target:self
                                   selector:@selector(tripEndTimerDidFire:)
                                   userInfo:nil
                                    repeats:NO];
}


+ (void)tripEndTimerDidFire:(NSTimer *)timer
{
    /* __dbhan: Go back to either passive mode and custom mode depending on which mode you were when you started the trip */
    // __dbhan: How do I retrieve the previous state?
    /* 1. set the send method
       2. set the sending frequency
       3. set the rate limit
       4. set the tracking limit */
    
    [[Geoloqi sharedInstance] setSendingMethodTo:[Geoloqi sharedInstance].recallSendingMethodState];
    [[Geoloqi sharedInstance] setDistanceFilterTo:[Geoloqi sharedInstance].recallDistanceFilterDistance];
    [[Geoloqi sharedInstance] setTrackingFrequencyTo:[Geoloqi sharedInstance].recallTrackingFrequency];
    [[Geoloqi sharedInstance] setSendingFrequencyTo:[Geoloqi sharedInstance].recallSendingFrequency];
#if (VERBOSE)
    NSLog (@"The sending method is = %i", [[Geoloqi sharedInstance] sendingMethodState]);
    NSLog (@"The distance filter is = %f", [[Geoloqi sharedInstance] distanceFilterDistance]);
    NSLog (@"The tracking frequency is = %f", [[Geoloqi sharedInstance] trackingFrequency] );
    NSLog (@"The sending frequency is =%f", [[Geoloqi sharedInstance] sendingFrequency]);
#endif
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
