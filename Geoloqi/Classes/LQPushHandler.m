//
//  LQPushHandler.m
//  Geoloqi
//
//  Created by Aaron Parecki on 12/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQPushHandler.h"
#import "SHKActivityIndicator.h"

@implementation LQPushHandler

@synthesize lastAlertURL, lastAlertToken;

- (id)myInit {
	self = [super init];
	lastAlertURL = [[NSString alloc] init];
	NSLog(@"Alloc url: %@", lastAlertURL);
	return self;
}

- (void)setLastAlertToken:(NSString *)_lastAlertToken {
    NSLog(@"Setting lastAlertToken: %@", _lastAlertToken);
    lastAlertToken = [_lastAlertToken retain];
}

/**
 * This is called from application: didReceiveRemoteNotification: which is called regardless of whether 
 * the app is in the foreground or background, but only if it is currently running.
 */
- (void)handlePush:(UIApplication *)application notification:(NSDictionary *)userInfo {
	NSString *title;
	NSString *type = [userInfo valueForKeyPath:@"geoloqi.type"];
	
	if(type && [@"geonote" isEqualToString:type]) {
		title = @"Geonote";
	} else if(type && [@"message" isEqualToString:type]) {
		title = @"Geoloqi";
	} else {
		title = @"Geoloqi";
	}
	
	if([type isEqualToString:@"shutdownPrompt"]){
		if([application applicationState] == UIApplicationStateActive) {
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
				[alert release];
			}
		} else {
			[[Geoloqi sharedInstance] stopLocationUpdates];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geoloqi"
															message:@"Location tracking is off"
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"Ok", nil];
			[alert show];
			[alert release];
		}
	} else if([type isEqualToString:@"startPrompt"]) {
		if([application applicationState] == UIApplicationStateActive) {
			// Received a push notification asking the user if they want to turn on location updates.
			// If updates are already on, don't bother actually prompting this.
			if([[Geoloqi sharedInstance] locationUpdatesState] == NO){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
																message:[userInfo valueForKeyPath:@"aps.alert.body"]
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes", nil];
				[alert setTag:kLQPushAlertStart];
				[alert show];
				[alert release];
			} else {
				[[Geoloqi sharedInstance] startLocationUpdates];
				gAppDelegate.tabBarController.selectedIndex = 1;
			}
		}
	} else {
		if([userInfo valueForKeyPath:@"aps.alert.body"] != nil) {
			UIAlertView *alert;
            self.lastAlertToken = [userInfo valueForKeyPath:@"geoloqi.token"];
			if([userInfo valueForKeyPath:@"geoloqi.link"] != nil) {
				alert = [[UIAlertView alloc] initWithTitle:title 
												   message:[userInfo valueForKeyPath:@"aps.alert.body"] 
												  delegate:self
										 cancelButtonTitle:@"Close"
										 otherButtonTitles:@"View", nil];
				self.lastAlertURL = [userInfo valueForKeyPath:@"geoloqi.link"];
				NSLog(@"Storing value in lastAlertURL: %@", lastAlertURL);
			} else {
				alert = [[UIAlertView alloc] initWithTitle:title 
												   message:[userInfo valueForKeyPath:@"aps.alert.body"] 
												  delegate:self
										 cancelButtonTitle:nil
										 otherButtonTitles:@"Ok", nil];
				self.lastAlertURL = nil;
			}
            // If the app is in the foreground, we want to display this as an alert. If in the background, do the action now.
			if([application applicationState] == UIApplicationStateActive) {
				[alert show];
				[alert setTag:kLQPushAlertGeonote];
			} else {
                if(self.lastAlertToken) {
                    [self trackReadPushNotificationAtLocation:nil];
                    [self startMonitoringLocationForPush];
                }
                if(self.lastAlertURL){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.lastAlertURL]];
                }
			}
			[alert release];
		}	
	}
}

- (void)handleLocalNotificationFromApp:(UIApplication *)app notif:(UILocalNotification *)notif {
	// A local notification came in but the app was in the foreground. This method is called immediately,
	// so we need to show them the alert and handle the response appropriately.

	if([app applicationState] == UIApplicationStateActive){
		// Don't prompt if tracking is already off. Probably won't happen anymore since the timers are cancelled when tracking is turned off.
		if([[Geoloqi sharedInstance] locationUpdatesState]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[notif.userInfo objectForKey:@"title"]
															message:[notif.userInfo objectForKey:@"description"]
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:notif.alertAction, nil];
			[alert show];
			[alert setTag:kLQPushAlertShutdown];
			[alert release];
		}
	} else {
		// The app just launched and it was running in the background. If they hit "Yes" then shut off updates
		[[Geoloqi sharedInstance] stopLocationUpdates];
	}
}

/*
- (void)handleLocalNotificationFromBackground:(UILocalNotification *)notif {
	// A local notification came in while the app was in the background. The user clicked the notification, 
	// and the app delegate called this message with the notification.
	
	// If the prompt was a battery alert message, stop location updates immediately because they clicked "Yes"
	if([[notif.userInfo objectForKey:@"title"] isEqualToString:@"Geoloqi Battery Alert"]){
		[[Geoloqi sharedInstance] stopLocationUpdates];
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Tracking is off!"];
	}else if([[notif.userInfo objectForKey:@"title"] isEqualToString:@"Stopped Sharing"]){
	// If the alert was because a shared link expired, stop location updates because they clicked "Yes"
		[[Geoloqi sharedInstance] stopLocationUpdates];
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Tracking is off!"];
	}
}
*/

- (void)trackReadPushNotificationAtLocation:(CLLocation *)location {

    if(bgTask) {
        NSLog(@"Ending background task %d", bgTask);
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
        NSLog(@"Background task timed out %d", bgTask);
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    NSLog(@"Beginning background task with id %d", bgTask);
    
    // Do the work associated with the task
    NSDictionary *params;
    
    if(location != nil) {
        NSLog(@"[Push tracking] Tracking push notification %@ location: %@", self.lastAlertToken, location);
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.lastAlertToken, @"token",
                  [NSString stringWithFormat:@"%f", location.coordinate.latitude], @"latitude",
                  [NSString stringWithFormat:@"%f", location.coordinate.longitude], @"longitude",
                  [NSString stringWithFormat:@"%f", location.horizontalAccuracy], @"accuracy",
                  nil];
    } else {
        NSLog(@"[Push tracking] Tracking push notification %@", self.lastAlertToken);
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.lastAlertToken, @"token", 
                  nil];
    }
    
    [[Geoloqi sharedInstance] trackPushNotificationView:params
                                               callback:^(NSError *error, NSString *responseBody) {
                                                   NSLog(@"Logged push read for token %@ accuracy: %@", self.lastAlertToken, [params objectForKey:@"accuracy"]);
                                                   if([[params objectForKey:@"accuracy"] floatValue] < 200.0) {
                                                       if(bgTask) {
                                                           NSLog(@"Ending background task %d", bgTask);
                                                           [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                                                           bgTask = UIBackgroundTaskInvalid;
                                                       }
                                                   }
                                               }];
        
}

- (void)startMonitoringLocationForPush {
    if (!locationManager) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.distanceFilter = 0;
        locationManager.desiredAccuracy = 30.0;
		locationManager.delegate = self;
	}
	
	[locationManager startUpdatingLocation];
}

/**
 * This is called when the app is launched from the button on a push notification
 */
- (void)handleLaunch:(NSDictionary *)launchOptions {
	
	NSLog(@"---- Handling launch from push notification");
	
	NSDictionary *data = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if(data == nil)
		return;
		
	NSString *type = [data valueForKeyPath:@"geoloqi.type"];

    self.lastAlertToken = [data valueForKeyPath:@"geoloqi.token"];
    
    [self trackReadPushNotificationAtLocation:nil];
    [self startMonitoringLocationForPush];

	if([type isEqualToString:@"startPrompt"]){

		[[Geoloqi sharedInstance] startLocationUpdates];
		gAppDelegate.tabBarController.selectedIndex = 1;
		
	}else if([type isEqualToString:@"shutdownPrompt"]){
		
		[[Geoloqi sharedInstance] stopLocationUpdates];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geoloqi"
														message:@"Location tracking is off"
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Ok", nil];
		[alert show];
		[alert release];
	}else{
		if([data valueForKeyPath:@"geoloqi.link"] != nil) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[data valueForKeyPath:@"geoloqi.link"]]];
		}
	}

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"Tapped button on alert view! Token: %@ URL: %@", self.lastAlertToken, self.lastAlertURL);
	
    if(self.lastAlertToken) {
        [self trackReadPushNotificationAtLocation:nil];
        [self startMonitoringLocationForPush];
    }
    
	switch([alertView tag]) {
		case kLQPushAlertShutdown:
			if(buttonIndex == 1){
				// Shut off location tracking now
				[[Geoloqi sharedInstance] stopLocationUpdates];
			}
			break;
		case kLQPushAlertStart:
			if(buttonIndex == 1){
				// Turn on location tracking now
				[[Geoloqi sharedInstance] startLocationUpdates];
			}
			break;
		case kLQPushAlertGeonote:
			if(buttonIndex == 1){
				// Clicked "view" and the push contained a link, so open a web browser
				NSLog(@"User clicked View, reading the value from lastAlertURL");
				NSLog(@"Value: %@", self.lastAlertURL);
				if(self.lastAlertURL != nil) {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.lastAlertURL]];
				}
			}
            break;
	}
}

#pragma mark LocationManager

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	
	// horizontalAccuracy is negative when the location is invalid
	// http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLLocation_Class/CLLocation/CLLocation.html
	if(newLocation.horizontalAccuracy >=0) {
        NSLog(@"[Push tracking] Got location update! %@", newLocation);
        
        // Wait for a location better than 200m before stopping
		if(newLocation.horizontalAccuracy < 200) {
            [locationManager stopUpdatingLocation];
        }
        
        [self trackReadPushNotificationAtLocation:newLocation];
	}
}

#pragma mark -

- (void)dealloc {
	[lastAlertURL release];
    [lastAlertToken release];
    [locationManager release];
	[super dealloc];
}

@end
