//
//  LQMapPinAnnotation.m
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-03-04.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQMapPinAnnotation.h"


@implementation LQMapPinAnnotation

@synthesize data, coordinate;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	self = [super init];
	
	self.data = dictionary;
	
	NSDictionary *position = [self.data objectForKey:@"position"];

	coordinate.latitude = [[position objectForKey:@"latitude"] doubleValue];
	coordinate.longitude = [[position objectForKey:@"longitude"] doubleValue];
	
	return self;
}

- (NSString *)title {
	return [self.data objectForKey:@"title"];
}

- (NSString *)subtitle {
	return [self.data objectForKey:@"subtitle"];
}

@end
