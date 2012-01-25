//
//  LQMapViewController.m
//  Geoloqi
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//
#import "Geoloqi.h"
#import "LQMapViewController.h"
#import "LQMapSignUpViewController.h"
#import "LQMutablePolyline.h"
#import "LQMutablePolylineView.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "LQMapPinAnnotation.h"

@implementation LQMapViewController

@synthesize map;
@synthesize controlBanner, trackingToggleSwitch, centerMapButton;// __dbhan: Gotcha
@synthesize anonymousBanner, anonymousSignUpButton;
@synthesize notificationBanner;
@synthesize signUpViewController;
@synthesize shareButton;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (void)viewDidLoad {
	[super viewDidLoad];

	// Set when the view loads, this is the first time the map has been viewed.
	// The map will center on the user's location as soon as it's received
	firstLoad = YES;
	
	// Don't attempt to load the history unless the user is logged in
	if([[Geoloqi sharedInstance] hasRefreshToken]) {
		[self reloadMapHistory];
	}else{
		// otherwise, listen for the notification that authentication was successful, then load the history
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reloadMapHistory)
													 name:LQAuthenticationSucceededNotification
												   object:nil];
	}

	[self.view addSubview:self.controlBanner];
	[self.controlBanner setCenter:(CGPoint){160.0, 22.0}];
	
	trackingToggleSwitch = [[CustomUISwitch alloc] initWithImageNamed:@"switch_dark.png" // __dbhan: Gotcha
															 withOnImageNamed:@"switch_dark_on.png"
															withOffImageNamed:@"switch_dark_off.png"];
	[trackingToggleSwitch setCenter:(CGPoint){266.0, 22.0}];
	[self.controlBanner addSubview: trackingToggleSwitch];
	[trackingToggleSwitch addTarget:self action:@selector(toggleTracking:) forControlEvents:UIControlEventValueChanged];


	// Set up the "anonymous" banner that will be shown if the user is anonymous
	UIImage *stretImg = [[UIImage imageNamed:@"anonButton.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
	[self.anonymousSignUpButton setBackgroundImage:stretImg forState:UIControlStateNormal];
	[self.view addSubview:self.anonymousBanner];
	[self.anonymousBanner setCenter:(CGPoint){160.0, 62.0}];
	
	// Set up the "notification" banner that may be shown
	[self.view addSubview:self.notificationBanner];
	[self.notificationBanner setCenter:(CGPoint){160.0, 102.0}];
	self.notificationBanner.hidden = YES;
	
	[gAppDelegate makeLQButton:self.shareButton];

	// Observe the Geoloqi location manager for updates
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationUpdated:)
												 name:LQLocationUpdateManagerDidUpdateLocationNotification
											   object:nil];

	// Observe the single location manager for updates
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(singleLocationUpdated:)
												 name:LQLocationUpdateManagerDidUpdateSingleLocationNotification
											   object:nil];

	// Observe the Geoloqi friend location manager for updates
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(friendLocationUpdated:)
												 name:LQLocationUpdateManagerDidUpdateFriendLocationNotification
											   object:nil];
	
	// Observe the map for location updates
	[map.userLocation addObserver:self  
					   forKeyPath:@"location"  
						  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
						  context:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
	self.anonymousBanner.hidden = ![GeoloqiAppDelegate isUserAnonymous];
	
	if(self.anonymousBanner.hidden) {
		[self.notificationBanner setCenter:(CGPoint){160.0, 62.0}];
	} else {
		[self.notificationBanner setCenter:(CGPoint){160.0, 102.0}];
	}
	
	[self.notificationBanner refreshForLocation:self.map.userLocation.location];
	
	[trackingToggleSwitch setOn:[[Geoloqi sharedInstance] locationUpdatesState] animated:animated]; // __dbhan: Gotcha => This is where it is turned off ... but how does locationUpdatesState set it to off?
	
	// [[Geoloqi sharedInstance] startFriendUpdates];
	
	viewRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
														 target:self
													   selector:@selector(viewRefreshTimerDidFire:)
													   userInfo:nil
														repeats:YES] retain];
}

- (void)viewRefreshTimerDidFire:(NSTimer *)timer {
	[trackingToggleSwitch setOn:[[Geoloqi sharedInstance] locationUpdatesState] animated:YES];
}

- (void)reloadMapHistory {
	[[Geoloqi sharedInstance] loadHistory:[NSDictionary dictionaryWithObjectsAndKeys:
										   @"200", @"count",
//										   @"3", @"thinning",
										   nil]
								 callback:[self historyLoadedCallback]];
}

- (LQHTTPRequestCallback)historyLoadedCallback {
	if (historyLoadedCallback) return historyLoadedCallback;
	return historyLoadedCallback = [^(NSError *error, NSString *responseBody) {

		NSLog(@"Map history loaded!");
		
		line = [[LQMutablePolyline alloc] init];
		[map addOverlay:line];

		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for location/history) \"%@\": %@", responseBody, err);
			[[Geoloqi sharedInstance] errorProcessingAPIRequest];
			return;
		}
		
		for (NSDictionary *point in [res objectForKey:@"points"]) {
			if ( ! [[point valueForKeyPath:@"location.position.horizontal_accuracy"] isEqual:[NSNull null]] &&
				[[point valueForKeyPath:@"location.position.horizontal_accuracy"] doubleValue] < 100) {
				CLLocationCoordinate2D coord;
				coord.latitude = [[point valueForKeyPath:@"location.position.latitude"] doubleValue];
				coord.longitude = [[point valueForKeyPath:@"location.position.longitude"] doubleValue];
				[line addCoordinate:coord];
			}
		}
		[lineView setNeedsDisplayInMapRect:line.boundingMapRect];
		
		if ( ! MKMapRectIsNull(line.boundingMapRect))
			[map setRegion:MKCoordinateRegionForMapRect(line.boundingMapRect)
				  animated:YES];
		
	} copy];
}

/*
- (void)requestFinished:(ASIHTTPRequest *)request {
	
	line = [[LQMutablePolyline alloc] init];
	[map addOverlay:line];
	
	if (![request error]) {
		NSData *json = [request responseData];
		NSError *err = nil;
		NSDictionary *points = [[CJSONDeserializer deserializer] deserializeAsDictionary:json
																				   error:&err];
		if (points) {
			for (NSDictionary *point in [points objectForKey:@"points"]) {
				if ( ! [[point valueForKeyPath:@"location.position.horizontal_accuracy"] isEqual:[NSNull null]] &&
                    [[point valueForKeyPath:@"location.position.horizontal_accuracy"] doubleValue] < 100) {
					CLLocationCoordinate2D coord;
					coord.latitude = [[point valueForKeyPath:@"location.position.latitude"] doubleValue];
					coord.longitude = [[point valueForKeyPath:@"location.position.longitude"] doubleValue];
					[line addCoordinate:coord];
				}
			}
			[lineView setNeedsDisplayInMapRect:line.boundingMapRect];
		}
	}
	
    if ( ! MKMapRectIsNull(line.boundingMapRect))
        [map setRegion:MKCoordinateRegionForMapRect(line.boundingMapRect)
              animated:YES];
}
*/

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Failed to get most recent 200 points: %@", [request error]);
}

- (void)updateLocationOnMap:(CLLocation *)loc {
	if(firstLoad)
    {
        [self zoomMapToLocation:loc];
		firstLoad = NO;
    }
	
	// Don't draw a point on the map if it's from the cell tower location.
	// Cell positions are reported with accuracy of 500 or above.
	if(loc.horizontalAccuracy < 300) {
		// add new location to polyline
		MKMapRect updateRect = [line addCoordinate:loc.coordinate];
		if (!MKMapRectIsNull(updateRect)) {
			//NSLog(@"Setting needs display in %@ on %@", MKStringFromMapRect(updateRect), lineView);
			[lineView setNeedsDisplayInMapRect:updateRect];
		}
	}
}

- (IBAction)tappedLocate:(id)sender
{
    CLLocation *location;
    
	//    if(location = [[Geoloqi sharedInstance] currentLocation])
	//    {
	//        [self zoomMapToLocation:location];
	//    }
	//    else if(mapView.userLocationVisible)
	//    {
	location = map.userLocation.location;
	[self zoomMapToLocation:location];
	//    }
}

// This method is called when our internal location manager receives a new point
- (void)locationUpdated:(NSNotification *)theNotification {
	CLLocation *newLoc = [[Geoloqi sharedInstance] currentLocation];
	[self updateLocationOnMap:newLoc];
}

// This method is called when our internal location manager receives a new point
- (void)singleLocationUpdated:(NSNotification *)theNotification {
	CLLocation *newLoc = [[Geoloqi sharedInstance] currentSingleLocation];
	[self updateLocationOnMap:newLoc];
}

- (void)friendLocationUpdated:(NSNotification *)notification {

	// Remove all previous annotations. This makes a pretty bad flicker, we'll have to figure something better out soon.
	if(map.annotations) {
		for (id annotation in [[map.annotations copy] autorelease]) {
			[map removeAnnotation:annotation];
		}
	}

	for(NSDictionary *point in [notification.userInfo objectForKey:@"friends"]){
		NSLog(@"Point: %@", point);
		
		[map addAnnotation:[[[LQMapPinAnnotation alloc] initWithDictionary:point] autorelease]];
	}	
}

// When the map view receives its location, this method is called
// This is separate from our internal location manager with the on/off switch
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context {

	if(firstLoad && map.userLocation)
    {
		[self.notificationBanner refreshForLocation:map.userLocation.location];
		
		if(![[Geoloqi sharedInstance] locationUpdatesState]){
			[self zoomMapToLocation:map.userLocation.location];
			firstLoad = NO;
		}
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
			viewForOverlay:(id <MKOverlay>)overlay {
	
	if ([overlay isKindOfClass:[LQMutablePolyline class]]) {
		if (!lineView) {
			lineView = [[LQMutablePolylineView alloc] initWithOverlay:overlay];
		}
		return lineView;
	}
	
	return nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillDisappear:(BOOL)animated {
	[viewRefreshTimer invalidate];
	[viewRefreshTimer release];
	viewRefreshTimer = nil;
	[[Geoloqi sharedInstance] stopFriendUpdates];
	if(map.annotations) {
		for (id annotation in [[map.annotations copy] autorelease]) {
			[map removeAnnotation:annotation];
		}
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)zoomMapToLocation:(CLLocation *)location
{
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.03;
    span.longitudeDelta = 0.03;
    
    MKCoordinateRegion region;
    
    [map setCenterCoordinate:location.coordinate animated:YES];
    
    region.center = location.coordinate;
    region.span   = span;
    
    [map setRegion:region animated:YES];
}

- (IBAction)signUp
{
	[self presentModalViewController:signUpViewController
							animated:YES];
}

- (void)toggleTracking:(UISwitch *)sender {
	if(sender.on){
		[[Geoloqi sharedInstance] startLocationUpdates];
	}else{
		[[Geoloqi sharedInstance] stopLocationUpdates];
	}
}

- (IBAction)shareButtonWasTapped:(UIButton *)button {

    gAppDelegate.mapViewController = self;
	LQShareViewController *shareView = [[LQShareViewController alloc] init];
	[self presentModalViewController:shareView animated:YES];
	[shareView release];

//	LQShareViewController *shareView = [[LQShareViewController alloc] init];
//	NSLog(@"Retain count: %d", [shareView retainCount]);
//	[self presentModalViewController:shareView animated:YES];
//	NSLog(@"Retain count: %d", [shareView retainCount]);
//	[shareView release];
//	NSLog(@"Retain count: %d", [shareView retainCount]);
}


- (void)dealloc {
	[lineView release];
	[line release];
	[map release];
	[controlBanner release];
	[trackingToggleSwitch release];
	[anonymousBanner release];
	[anonymousSignUpButton release];
	[historyLoadedCallback release];
    [super dealloc];
}


@end
