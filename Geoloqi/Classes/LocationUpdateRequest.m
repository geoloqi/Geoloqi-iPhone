//
//  LocationUpdateRequest.m
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "LocationUpdateRequest.h"

#import "CJSONDataSerializer.h"
#import "ISO8601DateFormatter.h"

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
		
		[locationArray addObject:dictionary];
	}
	
	[dateFormatter release];
	
	[self appendPostData:[[CJSONDataSerializer serializer] serializeArray:locationArray]];
}

@end
