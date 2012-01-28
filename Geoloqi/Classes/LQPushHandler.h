//
//  LQPushHandler.h
//  Geoloqi
//
//  Created by Aaron Parecki on 12/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Geoloqi.h"

enum {
	kLQPushAlertGeonote = 0,
	kLQPushAlertShutdown,
	kLQPushAlertStart
};

@interface LQPushHandler : NSObject <UIAlertViewDelegate, CLLocationManagerDelegate> {
	NSString *lastAlertURL;
    NSString *lastAlertToken;
	CLLocationManager *locationManager;
	LQHTTPRequestCallback locationUpdateCallback;
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) NSString *lastAlertURL;
@property (nonatomic, retain) NSString *lastAlertToken;

- (id)myInit;
- (void)handlePush:(UIApplication *)application notification:(NSDictionary *)userInfo;
- (void)handleLocalNotificationFromApp:(UIApplication *)app notif:(UILocalNotification *)notif;
//- (void)handleLocalNotificationFromBackground:(UILocalNotification *)notif;
- (void)handleLaunch:(NSDictionary *)launchOptions;
- (void)trackReadPushNotificationAtLocation:(CLLocation *)location;
- (void)startMonitoringLocationForPush;

@end
