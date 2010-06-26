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

@synthesize deviceKeyField, serverURLField;
@synthesize significantUpdateToggle;
@synthesize locationUpdateToggle;

- (void)viewDidLoad;
{
	[super viewDidLoad];
	
	GLLocationUpdateManager *locationUpdateManager = gAppDelegate.locationUpdateManager;
	
	significantUpdateToggle.selected = locationUpdateManager.significantUpdatesOnly;
	significantUpdateToggle.enabled = locationUpdateManager.locationUpdatesOn;
	
	deviceKeyField.text = locationUpdateManager.deviceKey;
	serverURLField.text = locationUpdateManager.serverURL;
}

- (IBAction)toggleSignificantUpdate;
{
	significantUpdateToggle.selected = !significantUpdateToggle.selected;
	gAppDelegate.locationUpdateManager.significantUpdatesOnly = significantUpdateToggle.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	if (textField == deviceKeyField) {
		gAppDelegate.locationUpdateManager.deviceKey = textField.text;
	} else if (textField == serverURLField) {
		gAppDelegate.locationUpdateManager.serverURL = textField.text;
	}
	[textField resignFirstResponder];
	
	return NO;
}

- (void)dealloc {
    
	[significantUpdateToggle release];
	significantUpdateToggle = nil;

	[deviceKeyField release];
	deviceKeyField = nil;


    [super dealloc];
}

@end
