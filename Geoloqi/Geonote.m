//
//  Geonote.m
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geonote.h"

@implementation Geonote

@synthesize friend;
@synthesize location;
@synthesize latitude;
@synthesize longitude;
@synthesize radius;
@synthesize text;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Geonote at %f, %f with radius %f: \"%@\"", 
																				 self.latitude, 
																				 self.longitude, 
																				 self.radius, 
																				 self.text];
}

@end