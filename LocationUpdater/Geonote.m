//
//  Geonote.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "Geonote.h"

@implementation Geonote

@synthesize friend;
@synthesize location;
@synthesize radius;
@synthesize text;

- (NSString *)description
{
    return [NSString stringWithFormat:@"Geonote to \"%@\" at %f, %f with radius %f: \"%@\"", self.friend, 
                                                                                             self.location.coordinate.latitude, 
                                                                                             self.location.coordinate.longitude, 
                                                                                             self.radius, 
                                                                                             self.text];
}

@end