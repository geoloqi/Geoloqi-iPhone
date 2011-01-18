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
#import "LQShareViewController.h"

@implementation LQMapViewController

@synthesize map;
@synthesize controlBanner, trackingToggleSwitch, checkInButton;
@synthesize anonymousBanner, anonymousSignUpButton;
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
	
	NSLog(@"MapDidLoad");

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
	
	trackingToggleSwitch = [[CustomUISwitch alloc] initWithImageNamed:@"switch_dark.png"
															 withOnImageNamed:@"switch_dark_on.png"
															withOffImageNamed:@"switch_dark_off.png"];
	[trackingToggleSwitch setCenter:(CGPoint){266.0, 22.0}];
	[self.controlBanner addSubview: trackingToggleSwitch];
	[trackingToggleSwitch addTarget:self action:@selector(toggleTracking:) forControlEvents:UIControlEventValueChanged];
	
	// If the user is anonymous, show a banner
	if( YES ){
		UIImage *stretImg = [[UIImage imageNamed:@"anonButton.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
		[self.anonymousSignUpButton setBackgroundImage:stretImg forState:UIControlStateNormal];
		[self.view addSubview:self.anonymousBanner];
		[self.anonymousBanner setCenter:(CGPoint){160.0, 62.0}];
	}
	
	/*
	UIImage *checkinBtnImg = [[UIImage imageNamed:@"checkinButton.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
	[self.checkInButton setBackgroundImage:checkinBtnImg forState:UIControlStateNormal];
	UIImage *checkinBtnDisabledImg = [[UIImage imageNamed:@"checkinButtonDisabled.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
	[self.checkInButton setBackgroundImage:checkinBtnDisabledImg forState:UIControlStateDisabled];
	[self.checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.checkInButton setTitleColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.3 alpha:1.0] forState:UIControlStateDisabled];
	 */
	[gAppDelegate makeLQButton:self.checkInButton];
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
	
	// Observe the map for location updates
	[map.userLocation addObserver:self  
					   forKeyPath:@"location"  
						  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
						  context:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
	self.anonymousBanner.hidden = ![GeoloqiAppDelegate isUserAnonymous];
	[trackingToggleSwitch setOn:[[Geoloqi sharedInstance] locationUpdatesState] animated:animated];
	[self updateCheckinButtonState];
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
	
	// add new location to polyline
	MKMapRect updateRect = [line addCoordinate:loc.coordinate];
	if (!MKMapRectIsNull(updateRect)) {
		//NSLog(@"Setting needs display in %@ on %@", MKStringFromMapRect(updateRect), lineView);
		[lineView setNeedsDisplayInMapRect:updateRect];
	}
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

// When the map view receives its location, this method is called
// This is separate from our internal location manager with the on/off switch
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context {

	if(firstLoad && map.userLocation)
    {
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
	[self updateCheckinButtonState];
}

- (void)updateCheckinButtonState {
	if([[Geoloqi sharedInstance] locationUpdatesState]) {
		// Disable the "send now" button, it will be enabled when a new location point has been received
		checkInButton.enabled = NO;
		//[checkInButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
	} else {
		// Enable the "send now" button since it will cause a single location point to be sent when tapped in this state
		checkInButton.enabled = YES;
		//[checkInButton setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
	}
}

- (IBAction)checkInButtonWasTapped:(UIButton *)button {
	// If passive location updates are off, get the user's location and send a single point
	[[Geoloqi sharedInstance] singleLocationUpdate];
}

- (IBAction)shareButtonWasTapped:(UIButton *)button {
	LQShareViewController *shareView = [[LQShareViewController alloc] init];
	[self presentModalViewController:shareView animated:YES];
}


- (void)dealloc {
	[lineView release];
	[line release];
	[map release];
	[controlBanner release];
	[checkInButton release];
	[trackingToggleSwitch release];
	[anonymousBanner release];
	[anonymousSignUpButton release];
	[historyLoadedCallback release];
    [super dealloc];
}


@end
