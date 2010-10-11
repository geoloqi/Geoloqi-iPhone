//
//  LocationUpdateManager.h
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

NSString *const GLLocationUpdateManagerDidUpdateLocationNotification;

@class LocationUpdateRequest;

@interface GLLocationUpdateManager : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	NSMutableArray *locationQueue;
	NSMutableArray *sendingLocations;
	BOOL significantUpdatesOnly;
	BOOL locationUpdatesOn;
	CLLocationDistance distanceFilterDistance;
	NSTimeInterval trackingFrequency;
	NSTimeInterval sendingFrequency;
	NSDate *lastSendDate;
	LocationUpdateRequest *currentRequest;
	NSTimer *sendingTimer;
	NSString *serverURL;
	
}

@property (readonly) NSArray *locationQueue;
@property (nonatomic, copy) NSDate *lastSendDate;
@property (nonatomic) NSTimeInterval trackingFrequency;
@property (nonatomic) NSTimeInterval sendingFrequency;
@property (nonatomic, assign) CLLocationDistance distanceFilterDistance;
@property (nonatomic, copy) NSString *deviceKey;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, copy) NSString *serverURL;

- (void)startOrStopMonitoringLocationIfNecessary;

@property (nonatomic, assign) BOOL significantUpdatesOnly;
@property (nonatomic, assign) BOOL locationUpdatesOn;

@end
