//
//  GeonoteRadiusViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GeonoteRadiusViewController.h"
#import "GeonoteMessageViewController.h"
#import "Geonote.h"

@implementation GeonoteRadiusViewController

@synthesize geonote;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ( ! self.geonote.radius)
        self.geonote.radius = kGeonoteRadiusArea;
    
    radiusPicker.selectedSegmentIndex = 1;
    
    mapView.centerCoordinate = self.geonote.location.coordinate;
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.geonote.location.coordinate radius:self.geonote.radius];
    
    [mapView setVisibleMapRect:circle.boundingMapRect];
    [mapView addOverlay:circle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Choose a radius";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Radius";
}

- (void)dealloc
{
    [geonote release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction)radiusPickerChanged:(UISegmentedControl *)picker
{
    CGFloat oldRadius = self.geonote.radius;
    
    if (picker.selectedSegmentIndex == 0 && self.geonote.radius != kGeonoteRadiusBlock)
        self.geonote.radius = kGeonoteRadiusBlock;

    else if (picker.selectedSegmentIndex == 1 && self.geonote.radius != kGeonoteRadiusArea)
        self.geonote.radius = kGeonoteRadiusArea;

    else if (picker.selectedSegmentIndex == 2 && self.geonote.radius != kGeonoteRadiusNeighborhood)
        self.geonote.radius = kGeonoteRadiusNeighborhood;

    else if (picker.selectedSegmentIndex == 3 && self.geonote.radius != kGeonoteRadiusCity)
        self.geonote.radius = kGeonoteRadiusCity;

    if (self.geonote.radius != oldRadius)
    {
        [mapView removeOverlays:mapView.overlays];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.geonote.location.coordinate radius:self.geonote.radius];
        
        [mapView addOverlay:circle];
        [mapView setVisibleMapRect:circle.boundingMapRect animated:NO];
    }
}

- (IBAction)tappedNext:(id)sender
{
    GeonoteMessageViewController *messageViewController = [[[GeonoteMessageViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    messageViewController.geonote = self.geonote;
    
    [self.navigationController pushViewController:messageViewController animated:YES];
}

#pragma mark -

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[[MKCircleView alloc] initWithCircle:(MKCircle *)overlay] autorelease];
    
    circleView.fillColor   = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
    circleView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    circleView.lineWidth   = 2.0;
    
    return circleView;
}
    
@end