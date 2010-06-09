//
//  LocationUpdateManager.m
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "LocationUpdateManager.h"

#import "LocationUpdateRequest.h"

NSString *LocationUpdateManagerUpdatesOnUserDefaultsKey = @"LocationUpdatesOn";
NSString *LocationUpdateManagerSignificantOnlyUserDefaultsKey = @"SignificantOnly";
NSString *LocationUpdateManagerDeviceKeyUserDefaultsKey = @"DeviceKey";
NSString *LocationUpdateManagerDistanceFilterDistanceDefaultsKey = @"DistanceFilterDistance";

@implementation LocationUpdateManager

@synthesize distanceFilterDistance;
@synthesize deviceKey;
@synthesize significantUpdatesOnly;
@synthesize locationUpdatesOn;

+ (void)initialize;
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:@"1234567890" forKey:LocationUpdateManagerDeviceKeyUserDefaultsKey]];
}

- (id) init {
	[super init];
	if (self == nil) return nil; 
	
	locationUpdatesOn = [[NSUserDefaults standardUserDefaults] boolForKey:LocationUpdateManagerUpdatesOnUserDefaultsKey];
	significantUpdatesOnly = [[NSUserDefaults standardUserDefaults] boolForKey:LocationUpdateManagerSignificantOnlyUserDefaultsKey];
	distanceFilterDistance = [[NSUserDefaults standardUserDefaults] boolForKey:LocationUpdateManagerDistanceFilterDistanceDefaultsKey];
	
	return self;
}

- (NSString *)deviceKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LocationUpdateManagerDeviceKeyUserDefaultsKey];
}

- (void)setDeviceKey:(NSString *)value {
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:LocationUpdateManagerDeviceKeyUserDefaultsKey];
}

- (void)setSignificantUpdatesOnly:(BOOL)value {
    if (significantUpdatesOnly != value) {
        significantUpdatesOnly = value;
		[[NSUserDefaults standardUserDefaults] setBool:significantUpdatesOnly forKey:LocationUpdateManagerSignificantOnlyUserDefaultsKey];
		[self startOrStopMonitoringLocationIfNecessary];
    }
}

- (void)setLocationUpdatesOn:(BOOL)value {
    if (locationUpdatesOn != value) {
        locationUpdatesOn = value;
		[[NSUserDefaults standardUserDefaults] setBool:locationUpdatesOn forKey:LocationUpdateManagerUpdatesOnUserDefaultsKey];
		[self startOrStopMonitoringLocationIfNecessary];
    }
}

- (void)setDistanceFilterDistance:(double)value {
    if (distanceFilterDistance != value) {
        distanceFilterDistance = value;
		locationManager.distanceFilter = distanceFilterDistance;
		[[NSUserDefaults standardUserDefaults] setDouble:distanceFilterDistance forKey:LocationUpdateManagerDistanceFilterDistanceDefaultsKey];
    }
}


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;
{	
	NSString *urlString = [NSString stringWithFormat:@"http://app.geoloqi.com/api/location/key/%@", self.deviceKey];
	
	LocationUpdateRequest *req = [LocationUpdateRequest requestWithURL:[NSURL URLWithString:urlString]];
	req.delegate = self;
	[req setLocationDataFromLocation:newLocation];
	[req startAsynchronous];
}

- (void)requestFinished:(LocationUpdateRequest *)inRequest;
{
	NSLog(@"Location update succeeded.");
}

- (void)requestFailed:(LocationUpdateRequest *)inRequest;
{
	NSLog(@"Location update failed.");
}

- (void)startOrStopMonitoringLocationIfNecessary;
{
	if (locationUpdatesOn) {
		if (!locationManager) {
			locationManager = [[CLLocationManager alloc] init];
			locationManager.distanceFilter = distanceFilterDistance;
			locationManager.delegate = self;
		}
		
		
		//significantLocationChangeMonitoringAvailable
		
		[locationManager startMonitoringSignificantLocationChanges];
		if (significantUpdatesOnly) {
			NSLog(@"Significant updates on.");
			[locationManager stopUpdatingLocation];
		} else {
			NSLog(@"Starting location updates");
			[locationManager startUpdatingLocation];
		}
	} else {
		[locationManager stopUpdatingLocation];
		[locationManager stopMonitoringSignificantLocationChanges];
		[locationManager release];
		locationManager = nil;
	}
}

- (void)dealloc
{
	[deviceKey release];
	deviceKey = nil;


	[super dealloc];
}

@end
