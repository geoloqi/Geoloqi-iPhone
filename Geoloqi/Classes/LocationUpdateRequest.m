//
//  LocationUpdateRequest.m
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LocationUpdateRequest.h"

#import "CJSONDataSerializer.h"
#import "ISO8601DateFormatter.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation LocationUpdateRequest

- (void)setLocationDataFromLocations:(NSArray *)locations {
	
	NSMutableArray *locationArray = [NSMutableArray arrayWithCapacity:[locations count]];
	
	ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
	dateFormatter.includeTime = YES;
	
	for (CLLocation *loc in locations) {
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
		
		NSDictionary *pos = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithDouble:loc.coordinate.latitude], @"latitude",
							 [NSNumber numberWithDouble:loc.coordinate.longitude], @"longitude",
							 [NSNumber numberWithDouble:loc.verticalAccuracy], @"vertical_accuracy",
							 [NSNumber numberWithDouble:loc.horizontalAccuracy], @"horizontal_accuracy",
							 nil];
		
		[dictionary setObject:[NSDictionary dictionaryWithObject:pos
														  forKey:@"position"]
					   forKey:@"location"];
		
		[dictionary setObject:[dateFormatter stringFromDate:loc.timestamp] forKey:@"date"];
		
		UIDevice *d = [UIDevice currentDevice];
		GLLocationUpdateManager *man = gAppDelegate.locationUpdateManager;
		
		// Raw information
		[dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithInt:round(man.distanceFilterDistance)], @"distance_filter",
							   [NSNumber numberWithInt:round(man.trackingFrequency)], @"tracking_limit",
							   [NSNumber numberWithInt:round(man.sendingFrequency)], @"rate_limit",
							   [NSNumber numberWithInt:round(d.batteryLevel*100)], @"battery",
							   nil]
					   forKey:@"raw"];
		// NB: it appears iOS rounds the reported battery level to increments of 5%
		
		// Client device information
		NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
		[dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:
							   [bundleInfo objectForKey:@"CFBundleDisplayName"], @"name",
							   [bundleInfo objectForKey:@"CFBundleVersion"], @"version",
							   [NSString stringWithFormat:@"%@ %@", d.systemName, d.systemVersion], @"platform",
							   [self hardware], @"hardware",
							   nil]
					   forKey:@"client"];
		
		[locationArray addObject:dictionary];
	}
	
	[dateFormatter release];
	
	[self appendPostData:[[CJSONDataSerializer serializer] serializeArray:locationArray]];
}

- (NSString *)hardware
{
	size_t size;
	
	// Set 'oldp' parameter to NULL to get the size of the data
	// returned so we can allocate appropriate amount of space
	sysctlbyname("hw.machine", NULL, &size, NULL, 0); 
	
	// Allocate the space to store name
	char *name = malloc(size);
	
	// Get the platform name
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	
	// Place name into a string
	NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	
	// Done with this
	free(name);
	
	return machine;
}


@end
