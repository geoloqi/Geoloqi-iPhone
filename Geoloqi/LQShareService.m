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

	[[Geoloqi sharedInstance] startLocationUpdates]; 
    
    
// __dbhan: We do not need to use notification as when the link expires, we either go to the HTTP(Passive/battery safe mode) of to the custom mode.
// __dbhan: If the user shuts off the app, the user anyway does not need to know that the tracking has been turned off. At this time it is a don't care
//__dbhan/__aaronpk: ORIGINAL_NOTES from our discussion drop the notification and put it back into the passive mode 
//__dbhan/__aaronpk: or the custom mode whichever state it was in  and get rid of the notification and cancellation ... 
//__dbhan: So we add a notification to see when the timer expires and then get a notification which calls a function to then take further actions
    
   //[NSTimer scheduledTimerWithTimeInterval:[_minutes intValue]*60
    [NSTimer scheduledTimerWithTimeInterval:([_minutes intValue]*60) / 12
                                     target:self
                                   selector:@selector(tripEndTimerDidFire:)
                                   userInfo:nil
                                    repeats:NO];
}


+ (void)tripEndTimerDidFire:(NSTimer *)timer
{
     //__dbhan: Go back to either passive mode and custom mode depending on which mode you were when you started the trip
    [[Geoloqi sharedInstance] setDistanceFilterTo:[Geoloqi sharedInstance].getRecallDistanceFilterDistance];
    [[Geoloqi sharedInstance] setTrackingFrequencyTo:[Geoloqi sharedInstance].getRecallTrackingFrequency];
    [[Geoloqi sharedInstance] setSendingFrequencyTo:[Geoloqi sharedInstance].getRecallSendingFrequency];
    [[Geoloqi sharedInstance] setTrackingModeTo:[Geoloqi sharedInstance].getRecallTrackingMode];
    NSLog(@"THE TRACKING PRAMETERS ARE TM, DFD, SF, TF : %i, %lf, %lf, %lf", 
          [[Geoloqi sharedInstance] getRecallTrackingMode],
          [[Geoloqi sharedInstance] getRecallDistanceFilterDistance],
          [[Geoloqi sharedInstance] getRecallSendingFrequency],
          [[Geoloqi sharedInstance] getRecallTrackingFrequency]
          );
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
