//
//  GeonoteMapViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GeonoteMapViewController.h"
#import "GeonoteRadiusViewController.h"
#import "Geonote.h"
#import "CJSONDeserializer.h"

@implementation GeonoteMapViewController

@synthesize geonote;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    if ( ! self.geonote.location)
        self.geonote.location = gAppDelegate.locationUpdateManager.currentLocation;
    
    self.navigationItem.titleView = searchBar;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarLocate.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(tappedLocate:)] autorelease];
    
    nextButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Choose a location";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Location";
    
    [searchBar resignFirstResponder];
}

- (void)dealloc
{
    [geonote release];
    
    [super dealloc];
}

#pragma mark -

- (void)tappedLocate:(id)sender
{
    CLLocation *location;
    
    if (gAppDelegate.locationUpdateManager.currentLocation)
    {
        location = gAppDelegate.locationUpdateManager.currentLocation;
        [self zoomMapToLocation:location];
    }
    else if (mapView.userLocationVisible)
    {
        location = mapView.userLocation.location;
        [self zoomMapToLocation:location];
    }
}

- (IBAction)tappedNext:(id)sender
{
    self.geonote.location = [[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude 
                                                        longitude:mapView.centerCoordinate.longitude] autorelease];

    GeonoteRadiusViewController *radiusViewController = [[[GeonoteRadiusViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    radiusViewController.geonote = self.geonote;
    
    [self.navigationController pushViewController:radiusViewController animated:YES];
}

- (void)zoomMapToLocation:(CLLocation *)location
{
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.05;
    span.longitudeDelta = 0.05;
    
    MKCoordinateRegion region;
    
    [mapView setCenterCoordinate:location.coordinate animated:YES];
    
    region.center = location.coordinate;
    region.span   = span;
    
    [mapView setRegion:region animated:YES];
}

#pragma mark -

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [mapView removeAnnotations:mapView.annotations];
    
    [aSearchBar resignFirstResponder];
    
    NSString *query = [aSearchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // http://code.google.com/apis/maps/documentation/geocoding/
    //
    NSString *requestString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?address=%@&sensor=true", query];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ( ! error && [(NSHTTPURLResponse *)response statusCode] >= 200 && [(NSHTTPURLResponse *)response statusCode] < 300)
    {
        NSDictionary *json = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        
        if ( ! error)
        {
            if ([[json objectForKey:@"results"] count])
            {
                NSDictionary *locationInfo = [[[[json objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
                
                CLLocation *resultLocation = [[[CLLocation alloc] initWithLatitude:[[locationInfo objectForKey:@"lat"] floatValue] 
                                                                         longitude:[[locationInfo objectForKey:@"lng"] floatValue]] autorelease];
                
                [self zoomMapToLocation:resultLocation];
                
                nextButton.enabled = YES;
            }
        }
    }
}

@end