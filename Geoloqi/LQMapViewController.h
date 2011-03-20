//
//  LQMapViewController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomUISwitch.h"
#import "LQNotificationBanner.h"
#import "LQShareViewController.h"

@class LQMutablePolyline, LQMutablePolylineView;

@interface LQMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
	LQMutablePolyline *line;
	LQMutablePolylineView *lineView;
	bool firstLoad;
	LQHTTPRequestCallback historyLoadedCallback;
	UIView *anonymousBanner;
	UIView *controlBanner;
	UIButton *anonymousSignUpButton;
	CustomUISwitch *trackingToggleSwitch;
	IBOutlet UIButton *shareButton;
	NSTimer *viewRefreshTimer;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UIView *controlBanner;
@property (nonatomic, retain) CustomUISwitch *trackingToggleSwitch;
@property (nonatomic, retain) IBOutlet UIButton *centerMapButton;
@property (nonatomic, retain) IBOutlet UIView *anonymousBanner;
@property (nonatomic, retain) IBOutlet UIButton *anonymousSignUpButton;
@property (nonatomic, retain) IBOutlet LQNotificationBanner *notificationBanner;
@property (nonatomic, retain) IBOutlet UIViewController *signUpViewController;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;

- (void)zoomMapToLocation:(CLLocation *)location;
- (void)reloadMapHistory;
- (LQHTTPRequestCallback)historyLoadedCallback;
- (IBAction)signUp;

- (void)toggleTracking:(UISwitch *)sender;
- (IBAction)shareButtonWasTapped:(UIButton *)button;

- (IBAction)tappedLocate:(id)sender;

@end
