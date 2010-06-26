//
//  Geonote.h
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGeonoteRadiusBlock         120.0f
#define kGeonoteRadiusArea          400.0f
#define kGeonoteRadiusNeighborhood 1200.0f
#define kGeonoteRadiusCity         6000.0f

@interface Geonote : NSObject
{
    id friend;
    CLLocation *location;
    CGFloat radius;
    NSString *text;
}

@property (nonatomic, retain) id friend;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, retain) NSString *text;

@end