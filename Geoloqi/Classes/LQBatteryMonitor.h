//
//  LQBatteryMonitor.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/17/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	kLQBatteryAlertFirst = 0,
	kLQBatteryAlertSecond
};

@interface LQBatteryMonitor : NSObject <UIAlertViewDelegate> {
	float lastBatteryLevel;
}

+ (LQBatteryMonitor *)sharedInstance;

- (void)start;

- (void)batteryLevelDidChange:(NSNotification *)notification;

- (void)batteryStateDidChange:(NSNotification *)notification;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
