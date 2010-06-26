//
//  GeonoteRadiusViewController.h
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Geonote;

@interface GeonoteRadiusViewController : UIViewController
{
    IBOutlet MKMapView *mapView;
    Geonote *geonote;
}

@property (nonatomic, retain) Geonote *geonote;

- (IBAction)tappedNext:(id)sender;

@end