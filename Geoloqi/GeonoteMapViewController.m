//
//  GeonoteMapViewController.m
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GeonoteMapViewController.h"
#import "GeonoteMessageViewController.h"
#import "Geonote.h"
#import "CJSONDeserializer.h"
#import "GeonoteMapViewGestureRecognizer.h"

@interface GeonoteMapViewController (GeonoteMapViewControllerPrivate)

- (void)hideRadiusOverlay;
- (void)showRadiusOverlay;

@end

#pragma mark -

@implementation GeonoteMapViewController

@synthesize geonote;
@synthesize geonotePin;
@synthesize geonoteTarget;

- (void)viewDidLoad
{
    [super viewDidLoad];

	//self.navigationController.navigationBar.tintColor = [UIColor blackColor];

	firstLoad = YES;
	
	// Create the Geonote object
	self.geonote = [[[Geonote alloc] init] autorelease];
	
    if (!self.geonote.location)
        self.geonote.location = [[Geoloqi sharedInstance] currentLocation];
	
    self.navigationItem.titleView = searchBar;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarLocate.png"]
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(tappedLocate:)] autorelease];

	// Observe the map for location updates
	[mapView.userLocation addObserver:self  
					   forKeyPath:@"location"  
						  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
						  context:NULL];

	GeonoteMapViewGestureRecognizer *tapInterceptor = [[GeonoteMapViewGestureRecognizer alloc] init];
	tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
		[self startedDraggingMap];
	};
	[mapView addGestureRecognizer:tapInterceptor];
	
    nextButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Choose a location";
	
	// When the Geonote screen first appears, start by zooming in on the current location
	// "tap" the locate button in the top right corner to do this
	[self tappedLocate:self];
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
    
//    if(location = [[Geoloqi sharedInstance] currentLocation])
//    {
//        [self zoomMapToLocation:location];
//    }
//    else if(mapView.userLocationVisible)
//    {
        location = mapView.userLocation.location;
        [self zoomMapToLocation:location];
//    }
}

- (IBAction)tappedNext:(id)sender
{
	NSLog(@"Confirmed location and radius of geonote. %@", [self.geonote description]);
	
    GeonoteMessageViewController *messageViewController = [[[GeonoteMessageViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    messageViewController.geonote = self.geonote;
    
    [self.navigationController pushViewController:messageViewController animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context {
	
	if(firstLoad && mapView.userLocation)
    {
        [self zoomMapToLocation:mapView.userLocation.location];
		
		firstLoad = NO;
    }
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

    [self setGeonotePosition];
}

- (void)setGeonotePosition
{
	MKCoordinateSpan currentSpan = mapView.region.span;
	
	// 111.0 km/degree of latitude * 1000 m/km * current delta * 20% of the half-screen width
	CGFloat desiredRadius = 111.0 * 1000 * currentSpan.latitudeDelta * 0.2;
	
	//NSLog(@"Setting position and radius of geonote");

    self.geonote.location = [[[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude 
                                                        longitude:mapView.centerCoordinate.longitude] autorelease];
	
	self.geonote.latitude = mapView.centerCoordinate.latitude;
	self.geonote.longitude = mapView.centerCoordinate.longitude;
	
	self.geonote.radius = desiredRadius;
	
	//NSLog(@"Geonote: %@", [self.geonote description]);
	nextButton.enabled = YES;
}

#pragma mark -

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [mapView removeAnnotations:mapView.annotations];
    
    [aSearchBar resignFirstResponder];
    
    NSString *query = [aSearchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // http://code.google.com/apis/maps/documentation/geocoding/
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

#pragma mark -

- (void)startedDraggingMap
{
	[UIView beginAnimations:@"" context:NULL];
	self.geonotePin.center = (CGPoint){self.geonotePin.center.x, 123};
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:UIViewAnimationCurveEaseOut];
	[UIView commitAnimations];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[UIView beginAnimations:@"" context:NULL];
	self.geonotePin.center = (CGPoint){self.geonotePin.center.x, 143};
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:UIViewAnimationCurveEaseIn];
	[UIView commitAnimations];

    [self setGeonotePosition];
}

@end