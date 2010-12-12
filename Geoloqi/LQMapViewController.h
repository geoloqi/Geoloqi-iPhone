//
//  LQMapViewController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class LQMutablePolyline, LQMutablePolylineView;

@interface LQMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
	LQMutablePolyline *line;
	LQMutablePolylineView *lineView;
	bool firstLoad;
	LQHTTPRequestCallback historyLoadedCallback;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;

- (IBAction)checkInWasTapped:(UIButton *)button;

- (void)zoomMapToLocation:(CLLocation *)location;
- (void)reloadMapHistory;
- (LQHTTPRequestCallback)historyLoadedCallback;

@end
