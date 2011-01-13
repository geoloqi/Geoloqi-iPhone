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
	UIView *controlBanner;
	UIButton *anonymousSignUpButton;
	IBOutlet UISwitch *trackingToggleSwitch;
	IBOutlet UIButton *checkInButton;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) IBOutlet UIView *controlBanner;
@property (nonatomic, retain) IBOutlet UIButton *checkInButton;
@property (nonatomic, retain) IBOutlet UISwitch *trackingToggleSwitch;
@property (nonatomic, retain) IBOutlet UIView *anonymousBanner;
@property (nonatomic, retain) IBOutlet UIButton *anonymousSignUpButton;
@property (nonatomic, retain) IBOutlet UIViewController *signUpViewController;

- (void)zoomMapToLocation:(CLLocation *)location;
- (void)reloadMapHistory;
- (LQHTTPRequestCallback)historyLoadedCallback;
- (IBAction)signUp;

- (void)toggleTracking:(UISwitch *)sender;
- (IBAction)checkInButtonWasTapped:(UIButton *)button;
- (void)updateCheckinButtonState;

@end
