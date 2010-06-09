//
//  GeonoteViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GeonoteViewController.h"


@implementation GeonoteViewController

@synthesize mapView;
@synthesize queryField;
@synthesize findMeButton;
@synthesize radiusLabel;
@synthesize radiusSlider;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLLocation *location = gAppDelegate.locationUpdateManager.lastKnownLocation;
    
    NSLog(@"last location: %@", [location description]);
    
    if (location)
    {
        [self.mapView setCenterCoordinate:location.coordinate];
        
        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
        
        [self.mapView setRegion:mapRegion animated:YES];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [mapView release];
    [queryField release];
    [findMeButton release];
    [radiusLabel release];
    [radiusSlider release];
    
    [super dealloc];
}


- (IBAction)tappedFindMe:(id)sender
{
    NSLog(@"find me");
}

- (IBAction)adjustedRadius:(id)sender
{
    NSLog(@"radius changed");
}


@end
