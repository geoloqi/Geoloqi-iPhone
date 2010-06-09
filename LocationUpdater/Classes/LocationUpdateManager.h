//
//  LocationUpdateManager.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface LocationUpdateManager : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	BOOL significantUpdatesOnly;
	BOOL locationUpdatesOn;
	double distanceFilterDistance;
}

@property (nonatomic, assign) double distanceFilterDistance;
@property (nonatomic, copy) NSString *deviceKey;

- (void)startOrStopMonitoringLocationIfNecessary;

@property (nonatomic, assign) BOOL significantUpdatesOnly;
@property (nonatomic, assign) BOOL locationUpdatesOn;

@end
