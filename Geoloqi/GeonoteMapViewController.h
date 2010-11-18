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
    Geonote *geonote;
	bool firstLoad;
}

@property (nonatomic, retain) Geonote *geonote;

- (void)tappedLocate:(id)sender;
- (IBAction)tappedNext:(id)sender;
- (void)zoomMapToLocation:(CLLocation *)location;

@end