//
//  GeonoteMapViewController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Geonote;

@interface GeonoteMapViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate>
{
    IBOutlet UISearchBar *searchBar;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *nextButton;
	IBOutlet UIView *geonotePin;
	IBOutlet UIView *geonotePinShadow;
	IBOutlet UIView *geonoteTarget;
    Geonote *geonote;
	bool firstLoad;
	bool firstNote;
}

@property (nonatomic, retain) Geonote *geonote;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIView *geonotePin;
@property (nonatomic, retain) IBOutlet UIView *geonotePinShadow;
@property (nonatomic, retain) IBOutlet UIView *geonoteTarget;

- (void)tappedLocate:(id)sender;
- (IBAction)tappedNext:(id)sender;
- (void)zoomMapToLocation:(CLLocation *)location;
- (void)zoomMapToLocation:(CLLocation *)location 
			 withViewport:(CLLocation *)southwest
				northeast:(CLLocation *)northeast;
- (void)startedDraggingMap;
- (void)setGeonotePosition;
- (IBAction)tappedHelp:(UIButton *)sender;

@end