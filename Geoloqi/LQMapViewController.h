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
	UIView *anonymousBanner;
	UIButton *anonymousSignUpButton;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UIView *anonymousBanner;
@property (nonatomic, retain) IBOutlet UIButton *anonymousSignUpButton;

- (void)zoomMapToLocation:(CLLocation *)location;
- (void)reloadMapHistory;
- (LQHTTPRequestCallback)historyLoadedCallback;

@end
