//
//  LocationUpdaterAppDelegate.m
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import "GeoloqiAppDelegate.h"
#import "LocationUpdaterViewController.h"
#import "GLAuthenticationManager.h"

GeoloqiAppDelegate *gAppDelegate;

@implementation GeoloqiAppDelegate

@synthesize locationUpdateManager;
@synthesize window, welcomeViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	gAppDelegate = self;
	
	self.locationUpdateManager = [[[GLLocationUpdateManager alloc] init] autorelease];
	[locationUpdateManager startOrStopMonitoringLocationIfNecessary];
	
    // Override point for customization after application launch.
	if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
		NSLog(@"Launched in response to location change update.");
	}
	
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

    if ( ! [[GLAuthenticationManager sharedManager] hasRefreshToken]) // we haven't logged in before
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationDidSucceed:) 
                                                     name:GLAuthenticationSucceededNotification 
                                                   object:nil];

        [tabBarController presentModalViewController:welcomeViewController animated:YES];
    }

	UIDevice *d = [UIDevice currentDevice];
	d.batteryMonitoringEnabled = YES;
//	NSLog(@"Name %@, Sys name %@, Sys version %@, Model %@, Idiom %d, Battery %f",
//		  d.name, d.systemName, d.systemVersion, d.model, d.userInterfaceIdiom, d.batteryLevel);

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [welcomeViewController release];
    [window release];
	[locationUpdateManager release];
    [super dealloc];
}

#pragma mark -

- (void)authenticationDidSucceed:(NSNotificationCenter *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:GLAuthenticationSucceededNotification 
                                                  object:nil];
    
    if (tabBarController.modalViewController && [tabBarController.modalViewController isKindOfClass:[welcomeViewController class]])
        [tabBarController dismissModalViewControllerAnimated:YES];
}

@end
