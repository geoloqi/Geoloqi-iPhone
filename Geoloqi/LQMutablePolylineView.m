//
//  LQMutablePolylineView.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQMutablePolylineView.h"
#import "LQMutablePolyline.h"

@interface LQMutablePolylineView () // Private methods
- (CGPathRef)createPathForPoints:(MKMapPoint *)points
                      pointCount:(NSUInteger)pointCount
                        clipRect:(MKMapRect)mapRect
                       zoomScale:(MKZoomScale)zoomScale;
@end


@implementation LQMutablePolylineView


- (void)drawMapRect:(MKMapRect)mapRect
		  zoomScale:(MKZoomScale)zoomScale
		  inContext:(CGContextRef)context {
	
//	NSLog(@"Drawing rect %@ @ zoom %f, actual rect %@, bounding %@", MKStringFromMapRect(mapRect), zoomScale,
//		  NSStringFromCGRect([self rectForMapRect:mapRect]), MKStringFromMapRect(self.overlay.boundingMapRect));
	
	LQMutablePolyline *line = (LQMutablePolyline *)self.overlay;
	
	CGFloat lineWidth = MKRoadWidthAtZoomScale(zoomScale);
    
    // outset the map rect by the line width so that points just outside
    // of the currently drawn rect are included in the generated path.
    MKMapRect clipRect = MKMapRectInset(mapRect, -lineWidth, -lineWidth);
    
    [line lockForReading];
    CGPathRef path = [self createPathForPoints:line.points
                                    pointCount:line.pointCount
                                      clipRect:clipRect
                                     zoomScale:zoomScale];
    [line unlock];
    
    if (path) {
        CGContextAddPath(context, path);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.75);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
        CGPathRelease(path);
    }
}


static BOOL lineIntersectsRect(MKMapPoint p0, MKMapPoint p1, MKMapRect r) {
    double minX = MIN(p0.x, p1.x);
    double minY = MIN(p0.y, p1.y);
    double maxX = MAX(p0.x, p1.x);
    double maxY = MAX(p0.y, p1.y);
    
    MKMapRect r2 = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return MKMapRectIntersectsRect(r, r2);
}

#define MIN_POINT_DELTA 5.0

- (CGPathRef)createPathForPoints:(MKMapPoint *)points
                      pointCount:(NSUInteger)pointCount
                        clipRect:(MKMapRect)mapRect
                       zoomScale:(MKZoomScale)zoomScale
{
    // The fastest way to draw a path in an MKOverlayView is to simplify the
    // geometry for the screen by eliding points that are too close together
    // and to omit any line segments that do not intersect the clipping rect.  
    // While it is possible to just add all the points and let CoreGraphics 
    // handle clipping and flatness, it is much faster to do it yourself:
    
	//NSLog(@"Creating path for points %p (%lu) clipped %@ zoom %f", points, pointCount, MKStringFromMapRect(mapRect), zoomScale);
	
    if (pointCount < 2)
        return NULL;
    
    CGMutablePathRef path = NULL;
    
    BOOL needsMove = YES;
    
#define POW2(a) ((a) * (a))
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    double minPointDelta = MIN_POINT_DELTA / zoomScale;
    double c2 = POW2(minPointDelta);
    
    MKMapPoint point, lastPoint = points[0];
    NSUInteger i;
    for (i = 1; i < pointCount - 1; i++) {
        point = points[i];
        double a2b2 = POW2(point.x - lastPoint.x) + POW2(point.y - lastPoint.y);
        if (a2b2 >= c2) {
            if (lineIntersectsRect(point, lastPoint, mapRect)) {
                if (!path) 
                    path = CGPathCreateMutable();
                if (needsMove) {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
            } else {
                // discontinuity, lift the pen
                needsMove = YES;
            }
            lastPoint = point;
        }
    }
    
#undef POW2
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    point = points[pointCount - 1];
    if (lineIntersectsRect(lastPoint, point, mapRect)) {
        if (!path)
            path = CGPathCreateMutable();
        if (needsMove) {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
    }
    
    return path;
}

- (void)dealloc {
    [super dealloc];
}


@end
