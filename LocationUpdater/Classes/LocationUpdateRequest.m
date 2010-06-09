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


- (void)setLocationDataFromLocation:(CLLocation *)inLocation;
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

	NSMutableDictionary *positionDictionary = [NSMutableDictionary dictionary];
	[positionDictionary setObject:[NSNumber numberWithDouble:inLocation.coordinate.latitude] forKey:@"latitude"];
	[positionDictionary setObject:[NSNumber numberWithDouble:inLocation.coordinate.longitude] forKey:@"longitude"];
	[positionDictionary setObject:[NSNumber numberWithDouble:inLocation.verticalAccuracy] forKey:@"vertical_accuracy"];
	[positionDictionary setObject:[NSNumber numberWithDouble:inLocation.horizontalAccuracy] forKey:@"horizontal_accuracy"];
	
	NSDictionary *locationDictionary = [NSDictionary dictionaryWithObject:positionDictionary forKey:@"position"];;
	[dictionary setObject:locationDictionary forKey:@"location"];
	
	ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
	dateFormatter.includeTime = YES;
	
	[dictionary setObject:[dateFormatter stringFromDate:inLocation.timestamp] forKey:@"date"];
	[dateFormatter release];
	
	NSArray *locationArray = [NSArray arrayWithObject:dictionary];
	
	[self appendPostData:[[CJSONDataSerializer serializer] serializeArray:locationArray]];
}

@end
