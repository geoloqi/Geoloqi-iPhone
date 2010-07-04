//
//  MapViewController.h
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GLMutablePolyline, GLMutablePolylineView;

@interface GLMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
	GLMutablePolyline *line;
	GLMutablePolylineView *lineView;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;

@end
