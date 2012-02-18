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
	
	float currentLevel = [UIDevice currentDevice].batteryLevel;

	// The simulator always returns -1, so ignore this check in the simulator
#if (!TARGET_IPHONE_SIMULATOR)
	if(currentLevel < 0) {
		// Unknown
		NSLog(@"Unknown battery level");
		return;
	}
#endif

	// If location updates are off, don't say anything
	if([[Geoloqi sharedInstance] locationUpdatesState]){

        float threshold = [[NSUserDefaults standardUserDefaults] integerForKey:@"autoShutoffPercent"] / 100.0;
        
		if(lastBatteryLevel > threshold && currentLevel <= threshold) {
			// If it was last above 20% and is now below 20%, shut off location updates
			
            [[Geoloqi sharedInstance] stopLocationUpdates];
            NSLog(@"Shutting off location updates because battery dropped below %d%%", (int)(threshold*100));
		}
			
	} // end if location updates are off

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
