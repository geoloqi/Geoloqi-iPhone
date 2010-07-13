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
@synthesize startingRegion;
@synthesize startingCenterCoordinate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    mapView.region = self.startingRegion;
    mapView.centerCoordinate = self.startingCenterCoordinate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Choose a radius";
    
    if ( ! self.geonote.radius)
        self.geonote.radius = kGeonoteRadiusArea;
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

- (IBAction)tappedNext:(id)sender
{
    GeonoteMessageViewController *messageViewController = [[[GeonoteMessageViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    messageViewController.geonote = self.geonote;
    
    [self.navigationController pushViewController:messageViewController animated:YES];
}

@end