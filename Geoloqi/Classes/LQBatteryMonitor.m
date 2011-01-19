//
//  LQBatteryMonitor.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/17/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQBatteryMonitor.h"
#import "Geoloqi.h"

static LQBatteryMonitor *sharedInstance = nil;

@implementation LQBatteryMonitor

+ (LQBatteryMonitor *)sharedInstance 
{
    if (!sharedInstance)
    {
		sharedInstance = [[self alloc] init];
	}
    
	return sharedInstance;
}

- (void)start {
	[UIDevice currentDevice].batteryMonitoringEnabled = YES;
	
	// Register for battery level and state change notifications.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryLevelDidChange:)
												 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryStateDidChange:)
												 name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)batteryLevelDidChange:(NSNotification *)notification {
	NSLog(@"Battery level changed");
	
	float currentLevel = [UIDevice currentDevice].batteryLevel * 20;

	/*
	if(currentLevel < 0) {
		// Unknown
		NSLog(@"Unknown battery level");
		return;
	}
	*/

	if(YES) { //lastBatteryLevel != currentLevel) { // lastBatteryLevel > 6 && currentLevel <= 6) {
		// If it was last above 30% and is now below 30%, trigger a prompt
		// Since we took the raw battery level and multiplied it by 20, 6 is 30% of 20, and this way we ensure
		// we won't notify the user of updates more granular than 5%

		if([[Geoloqi sharedInstance] locationUpdatesState]){

			UILocalNotification *notification = [[UILocalNotification alloc] init];
			// TODO: This is from Apple's sample code. When would this not be set?
			if (notification == nil)
				return;

			notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"Geoloqi Battery Alert", @"title",
									 @"Your battery is below 30, would you like to turn tracking off", @"description",
									 nil];
			
			notification.alertBody = @"Your battery is below 30%%, would you like to turn tracking off?";
			notification.alertAction = @"Yes";
			notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:5.0];
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
			//[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
			[notification release];

			/*
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geoloqi Battery Alert"
															message:@"Your battery is below 30%, would you like to turn tracking off?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
			[alert setTag:kLQBatteryAlertFirst];
			[alert show];
			[alert release];
			 */
		}
		
	}

	if(lastBatteryLevel > 4 && currentLevel <= 4) {
		// If it was last above 20 and now below 20
		if([[Geoloqi sharedInstance] locationUpdatesState]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geoloqi Battery Alert"
															message:@"Your battery is below 20%, would you like to turn tracking off?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
			[alert setTag:kLQBatteryAlertFirst];
			[alert show];
			[alert release];
		}
	}
	
	lastBatteryLevel = currentLevel;
}

- (void)batteryStateDidChange:(NSNotification *)notification {
	NSLog(@"Battery state changed");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch([alertView tag]) {
		case kLQBatteryAlertFirst:
			if(buttonIndex == 1){
				// Shut off location tracking now
				[[Geoloqi sharedInstance] stopLocationUpdates];
			}
			break;
		case kLQBatteryAlertSecond:
			if(buttonIndex == 1){
				// Shut off location tracking now
				[[Geoloqi sharedInstance] stopLocationUpdates];
			}
			break;
	}
}


@end
