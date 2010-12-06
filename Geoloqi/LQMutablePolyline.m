//
//  LQMutablePolyline.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQMutablePolyline.h"

@interface LQMutablePolyline () // Private methods
- (BOOL)lockForWriting;
@end

#define INITIAL_POINT_SPACE 100
#define MINIMUM_DELTA_METERS 10.0

@implementation LQMutablePolyline

@synthesize boundingMapRect, coordinate;
@synthesize points, pointCount;

- (id)init {
	if (self = [super init]) {
		boundingMapRect = MKMapRectNull;//MKMapRectWorld;
        // Initialize point storage
        pointSpace = INITIAL_POINT_SPACE;
        points = malloc(sizeof(MKMapPoint) * pointSpace);
		
		int result = pthread_rwlock_init(&lock, NULL);
		if (result != 0) {
			NSLog(@"Error initializing read-write lock (error %d), aborting!", result);
			[self release];
			return nil;
		}
	}
	return self;
}

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord {
	NSLog(@"Adding coordinate %f,%f", coord.longitude, coord.latitude);
	
	if (![self lockForWriting]) return MKMapRectNull;
	
	// Convert a CLLocationCoordinate2D to an MKMapPoint
	MKMapPoint newPoint = MKMapPointForCoordinate(coord);
	MKMapPoint prevPoint = points[pointCount - 1];
	
	// Get the distance between this new point and the previous point.
	CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
	MKMapRect updateRect = MKMapRectNull;
	
	if (metersApart > MINIMUM_DELTA_METERS) {
		// Grow the points array if necessary
		if (pointSpace == pointCount) {
			pointSpace *= 2;
			points = realloc(points, sizeof(MKMapPoint) * pointSpace);
			// egad, I just spent hours failing to debug this, when the sample code was wrong. fml
		}
		
		// Add the new point to the points array
		points[pointCount] = newPoint;
		pointCount++;
		
		boundingMapRect = MKMapRectUnion(boundingMapRect, MKMapRectMake(newPoint.x, newPoint.y, 0, 0));
		
		
		// Compute MKMapRect bounding prevPoint and newPoint
		double minX = MIN(newPoint.x, prevPoint.x);
		double minY = MIN(newPoint.y, prevPoint.y);
		double maxX = MAX(newPoint.x, prevPoint.x);
		double maxY = MAX(newPoint.y, prevPoint.y);
		
		updateRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
	}
	
	[self unlock];
	
	//NSLog(@"Update rect %@", MKStringFromMapRect(updateRect));
	return updateRect;
}


- (BOOL)lockForReading {
	int result = pthread_rwlock_rdlock(&lock);
	if (result != 0) {
		NSLog(@"Error acquiring read lock: %d!", result);
		return NO;
	}
	return YES;
}
- (BOOL)unlock {
	int result = pthread_rwlock_unlock(&lock);
	if (result != 0) {
		NSLog(@"Error unlocking read-write lock: %d!", result);
		return NO;
	}
	return YES;
}
- (BOOL)lockForWriting {
	int result = pthread_rwlock_wrlock(&lock);
	if (result != 0) {
		NSLog(@"Error acquiring write lock: %d!", result);
		return NO;
	}
	return YES;
}
- (void)dealloc {
	NSLog(@"Dealloc polyline %@", self);
	int result = pthread_rwlock_destroy(&lock);
	if (result != 0) {
		NSLog(@"Error destroying read-write lock: %d", result);
	}
	if (points) free(points);
	[super dealloc];
}

@end
