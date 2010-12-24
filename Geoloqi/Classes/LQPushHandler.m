//
//  LQPushHandler.m
//  Geoloqi
//
//  Created by Aaron Parecki on 12/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQPushHandler.h"

@implementation LQPushHandler

- (void)handlePush:(NSDictionary *)userInfo {
	NSString *title;
	NSString *type = [userInfo valueForKeyPath:@"geoloqi.type"];
	
	if(type && [@"geonote" isEqualToString:type]) {
		title = @"Geonote";
	} else if(type && [@"message" isEqualToString:type]) {
		title = @"Message";
	} else {
		title = @"Geoloqi";
	}
	
	if([type isEqualToString:@"shutdownPrompt"]){
		// Received a push notification asking the user if they want to shut off location updates.
		// If updates have already been turned off, don't bother actually prompting this.
		if([[Geoloqi sharedInstance] locationUpdatesState]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
															message:[userInfo valueForKeyPath:@"aps.alert.body"]
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
			[alert setTag:kLQPushAlertShutdown];
			[alert show];
		}
	} else {
		if([userInfo valueForKeyPath:@"aps.alert.body"] != nil) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
															message:[userInfo valueForKeyPath:@"aps.alert.body"] 
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"Ok", nil];
			[alert show];
			[alert setTag:kLQPushAlertGeonote];
		}	
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	switch([alertView tag]) {
		case kLQPushAlertShutdown:
			if(buttonIndex == 1){
				// Shut off location tracking now
				[[Geoloqi sharedInstance] stopLocationUpdates];
			}
			break;
	}
	[alertView release];
}

@end
