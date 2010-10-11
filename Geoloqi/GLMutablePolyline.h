//
//  GLMutablePolyline.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <pthread.h>

@interface GLMutablePolyline : NSObject <MKOverlay> {
	// MKOverlay stuff
	MKMapRect boundingMapRect;
	CLLocationCoordinate2D coordinate;
	
	// Points
	MKMapPoint *points;
    NSUInteger pointCount;
    NSUInteger pointSpace;
	
	// Read-write lock for MapKit asynchronous drawing
    pthread_rwlock_t lock;
}

- (BOOL)lockForReading;
- (BOOL)unlock;
- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord;

@property (nonatomic, readonly) MKMapPoint *points;
@property (nonatomic, readonly) NSUInteger pointCount;

@end
