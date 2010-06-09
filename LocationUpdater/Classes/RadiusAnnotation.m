//
//  RadiusAnnotation.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "RadiusAnnotation.h"

@implementation RadiusAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

- (NSString *)title
{
    return @"You are here";
}

@end