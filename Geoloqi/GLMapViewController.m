//
//  MapViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GLMapViewController.h"
#import "GLMutablePolyline.h"
#import "GLMutablePolylineView.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"

@implementation GLMapViewController

@synthesize map;

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
	
	ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:
						   [NSURL URLWithString:
							[NSString stringWithFormat:
							 @"http://test.geoloqi.com/api/location_history/key/%@/points/200",
							 gAppDelegate.locationUpdateManager.deviceKey]]];
	req.delegate = self;
	[req startAsynchronous];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationUpdated:)
												 name:GLLocationUpdateManagerDidUpdateLocationNotification
											   object:nil];
}
- (void)requestFinished:(ASIHTTPRequest *)request {
	
	line = [[GLMutablePolyline alloc] init];
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

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Failed to get most recent 200 points: %@", [request error]);
}

- (void)locationUpdated:(NSNotification *)theNotification {
	CLLocation *newLoc = gAppDelegate.locationUpdateManager.currentLocation;
	// add new location to polyline
	MKMapRect updateRect = [line addCoordinate:newLoc.coordinate];
	if (!MKMapRectIsNull(updateRect)) {
		//NSLog(@"Setting needs display in %@ on %@", MKStringFromMapRect(updateRect), lineView);
		[lineView setNeedsDisplayInMapRect:updateRect];
	}
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
			viewForOverlay:(id <MKOverlay>)overlay {
	
	if ([overlay isKindOfClass:[GLMutablePolyline class]]) {
		if (!lineView) {
			lineView = [[GLMutablePolylineView alloc] initWithOverlay:overlay];
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


- (void)dealloc {
	[lineView release];
	[line release];
	[map release];
    [super dealloc];
}


@end
