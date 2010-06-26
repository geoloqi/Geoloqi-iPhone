//
//  LocationUpdateManager.m
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "GLLocationUpdateManager.h"

#import "LocationUpdateRequest.h"

NSString *const LocationUpdateManagerServerURLKey = @"LocationUpdateManagerServerURLKey";
NSString *const LocationUpdateManagerUpdatesOnUserDefaultsKey = @"LocationUpdateManagerUpdatesOnUserDefaultsKey";
NSString *const LocationUpdateManagerSignificantOnlyUserDefaultsKey = @"LocationUpdateManagerSignificantOnlyUserDefaultsKey";
NSString *const LocationUpdateManagerDeviceKeyUserDefaultsKey = @"LocationUpdateManagerDeviceKeyUserDefaultsKey";
NSString *const LocationUpdateManagerDistanceFilterDistanceDefaultsKey = @"LocationUpdateManagerDistanceFilterDistanceDefaultsKey";
NSString *const LocationUpdateManagerTrackingFrequencyDefaultsKey = @"LocationUpdateManagerTrackingFrequencyDefaultsKey";
NSString *const LocationUpdateManagerSendingFrequencyDefaultsKey = @"LocationUpdateManagerSendingFrequencyDefaultsKey";

NSString *const GLLocationUpdateManagerDidUpdateLocationNotification = @"GLLocationUpdateManagerDidUpdateLocationNotification";

@interface GLLocationUpdateManager () // Private methods
- (void)processQueue:(NSTimer *)theTimer;
- (void)scheduleSending;
@end



@implementation GLLocationUpdateManager

@synthesize currentLocation, lastSendDate, locationQueue;
@synthesize distanceFilterDistance, trackingFrequency, sendingFrequency;
@synthesize deviceKey, serverURL;
@synthesize significantUpdatesOnly;
@synthesize locationUpdatesOn;

+ (void)initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  @"1234567890", LocationUpdateManagerDeviceKeyUserDefaultsKey,
	  @"http://api.geoloqi.com/api/location/key/%@", LocationUpdateManagerServerURLKey,
	  nil]];
}

- (id) init {
	if (self = [super init]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		locationUpdatesOn = [defaults boolForKey:LocationUpdateManagerUpdatesOnUserDefaultsKey];
		significantUpdatesOnly = [defaults boolForKey:LocationUpdateManagerSignificantOnlyUserDefaultsKey];
		
		distanceFilterDistance = [defaults doubleForKey:LocationUpdateManagerDistanceFilterDistanceDefaultsKey];
		trackingFrequency = [defaults doubleForKey:LocationUpdateManagerTrackingFrequencyDefaultsKey];
		sendingFrequency = [defaults doubleForKey:LocationUpdateManagerSendingFrequencyDefaultsKey];
		
		locationQueue = [[NSMutableArray alloc] init];
		sendingLocations = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSString *)deviceKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LocationUpdateManagerDeviceKeyUserDefaultsKey];
}

- (void)setDeviceKey:(NSString *)value {
	[[NSUserDefaults standardUserDefaults] setObject:value
											  forKey:LocationUpdateManagerDeviceKeyUserDefaultsKey];
}
- (NSString *)serverURL {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LocationUpdateManagerServerURLKey];
}
- (void)setServerURL:(NSString *)new {
	[[NSUserDefaults standardUserDefaults] setObject:new
											  forKey:LocationUpdateManagerServerURLKey];
}


- (void)setSignificantUpdatesOnly:(BOOL)value {
    if (significantUpdatesOnly != value) {
        significantUpdatesOnly = value;
		[[NSUserDefaults standardUserDefaults] setBool:significantUpdatesOnly
												forKey:LocationUpdateManagerSignificantOnlyUserDefaultsKey];
		[self startOrStopMonitoringLocationIfNecessary];
    }
}

- (void)setLocationUpdatesOn:(BOOL)value {
    if (locationUpdatesOn != value) {
        locationUpdatesOn = value;
		[[NSUserDefaults standardUserDefaults] setBool:locationUpdatesOn
												forKey:LocationUpdateManagerUpdatesOnUserDefaultsKey];
		[self startOrStopMonitoringLocationIfNecessary];
    }
}

- (void)setDistanceFilterDistance:(double)value {
    if (distanceFilterDistance != value) {
        distanceFilterDistance = value;
		locationManager.distanceFilter = distanceFilterDistance;
		[[NSUserDefaults standardUserDefaults] setDouble:distanceFilterDistance
												  forKey:LocationUpdateManagerDistanceFilterDistanceDefaultsKey];
    }
}
- (void)setTrackingFrequency:(NSTimeInterval)freq {
    if (trackingFrequency != freq) {
        trackingFrequency = freq;
		[[NSUserDefaults standardUserDefaults] setDouble:trackingFrequency
												  forKey:LocationUpdateManagerTrackingFrequencyDefaultsKey];
    }
}
- (void)setSendingFrequency:(NSTimeInterval)freq {
    if (sendingFrequency != freq) {
        sendingFrequency = freq;
		[[NSUserDefaults standardUserDefaults] setDouble:sendingFrequency
												  forKey:LocationUpdateManagerSendingFrequencyDefaultsKey];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	
	// Only capture points as frequently as the min. tracking interval
	// These checks are done against the last saved location (currentLocation)
	if (!oldLocation || // first update
		([newLocation distanceFromLocation:self.currentLocation] > distanceFilterDistance && // check min. distance
		 [newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp] > trackingFrequency)) {
		
		// currentLocation is always the point that was last accepted into the queue.
		self.currentLocation = newLocation;
		
		NSLog(@"Updated to location %@ from %@", newLocation, oldLocation);
		
		// Notify observers about the location change
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:GLLocationUpdateManagerDidUpdateLocationNotification
		 object:self];
		
		// Add the location to the queue
		[locationQueue addObject:newLocation];
		
		// Send the points if possible
		[self scheduleSending];
	} else {
		NSLog(@"Location update (to %@; from %@) rejected", newLocation, oldLocation);
	}
}

- (void)scheduleSending {
	NSLog(@"Checking queue");
	
	// Don't send if there aren't any points
	if ([locationQueue count] <= 0) return;
	
	// Data has been sent recently, don't send again
	if (self.lastSendDate && -[self.lastSendDate timeIntervalSinceNow] < sendingFrequency) {
		if (!sendingTimer) {
			// Set up a timer to make sure the data is sent as soon as possible
			sendingTimer = [[NSTimer alloc] initWithFireDate:[self.lastSendDate
															  dateByAddingTimeInterval:sendingFrequency]
													interval:0
													  target:self
													selector:@selector(processQueue:)
													userInfo:nil
													 repeats:NO];
			[[NSRunLoop mainRunLoop] addTimer:sendingTimer
									  forMode:NSDefaultRunLoopMode];
			
			NSLog(@"Scheduling queue processing for %@ (now %@)",
				  [sendingTimer fireDate], [NSDate date]);
		}
	} else {
		NSLog(@"Processing queue immediately");
		[self processQueue:nil];
	}
}
- (void)processQueue:(NSTimer *)theTimer {
	
	[sendingTimer invalidate];
	[sendingTimer release];
	sendingTimer = nil;
	
	// Don't send 2 requests at once
	if (currentRequest.inProgress) {
		NSLog(@"Processing queue aborted: request in progress");
		return;
	}
	
	NSLog(@"Processing queue %@", locationQueue);
	
	NSString *urlString = [NSString stringWithFormat:
						   self.serverURL, self.deviceKey];
	
	currentRequest = [[LocationUpdateRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
	currentRequest.delegate = self;
	[currentRequest setLocationDataFromLocations:locationQueue];
	[currentRequest startAsynchronous];
	
	// Move the points into a separate array
	[sendingLocations addObjectsFromArray:locationQueue];
	[locationQueue removeAllObjects];
}

- (void)requestFinished:(LocationUpdateRequest *)inRequest {
	NSLog(@"Location update succeeded.");
	self.lastSendDate = [NSDate date];
	[currentRequest release];
	currentRequest = nil;
	
	// Clear the list of points being sent
	[sendingLocations removeAllObjects];
	
	[self scheduleSending];
}

- (void)requestFailed:(LocationUpdateRequest *)inRequest {
	NSLog(@"Location update failed.");
	[currentRequest release];
	currentRequest = nil;
	
	// Put the attempted points back in the queue
	for (CLLocation *loc in sendingLocations) {
		[locationQueue insertObject:loc atIndex:0];
	}
	[sendingLocations removeAllObjects];
	
	[self scheduleSending];
}

- (void)startOrStopMonitoringLocationIfNecessary {
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

- (void)dealloc {
	[sendingTimer invalidate];
	[sendingTimer release];
	[locationManager release];
	[lastSendDate release];
	[currentLocation release];
	[locationQueue release];
	[sendingLocations release];
	[deviceKey release];
	
	[super dealloc];
}

@end
