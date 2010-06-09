//
//  LocationUpdaterViewController.m
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import "LocationUpdaterViewController.h"

#import "LocationUpdateRequest.h"

@implementation LocationUpdaterViewController

@synthesize deviceKeyField;
@synthesize distanceFilterSlider;
@synthesize significantUpdateToggle;
@synthesize locationUpdateToggle;

- (void)viewDidLoad;
{
	[super viewDidLoad];
	
	LocationUpdateManager *locationUpdateManager = gAppDelegate.locationUpdateManager;
	
	locationUpdateToggle.selected = locationUpdateManager.locationUpdatesOn;
	significantUpdateToggle.selected = locationUpdateManager.significantUpdatesOnly;
	significantUpdateToggle.enabled = locationUpdateToggle.selected;
	
	deviceKeyField.text = locationUpdateManager.deviceKey;
	distanceFilterSlider.value = locationUpdateManager.distanceFilterDistance;
}

- (IBAction)toggleSignificantUpdate;
{
	significantUpdateToggle.selected = !significantUpdateToggle.selected;
	gAppDelegate.locationUpdateManager.significantUpdatesOnly = significantUpdateToggle.selected;
}
- (IBAction)toggleLocationUpdate;
{
	locationUpdateToggle.selected = !locationUpdateToggle.selected;
	gAppDelegate.locationUpdateManager.locationUpdatesOn = locationUpdateToggle.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	gAppDelegate.locationUpdateManager.deviceKey = textField.text;
	[textField resignFirstResponder];

}

- (IBAction)distanceFilterChanged:(UISlider *)sender;
{
	gAppDelegate.locationUpdateManager.distanceFilterDistance = sender.value;
	distanceFilterLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

- (void)dealloc {
	
	[significantUpdateToggle release];
	significantUpdateToggle = nil;
	[locationUpdateToggle release];
	locationUpdateToggle = nil;

	[distanceFilterSlider release];
	distanceFilterSlider = nil;

	[deviceKeyField release];
	deviceKeyField = nil;


    [super dealloc];
}

@end
