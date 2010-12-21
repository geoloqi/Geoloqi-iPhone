//
//  GeoloqiAppDelegate.m
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQConstants.h"
#import "GeoloqiAppDelegate.h"
#import "SHK.h"

GeoloqiAppDelegate *gAppDelegate;

@implementation GeoloqiAppDelegate

@synthesize deviceToken;
@synthesize window, welcomeViewController;
@synthesize tabBarController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	gAppDelegate = self;

	// IMPORTANT: Set up OAuth prior to making network calls to the geoloqi server.
    [[Geoloqi sharedInstance] setOauthClientID:LQ_OAUTH_CLIENT_ID secret:LQ_OAUTH_SECRET];

    
	// Starts location updates if the last state of the app had updates turned on
	[[Geoloqi sharedInstance] startOrStopMonitoringLocationIfNecessary];
	
    // Override point for customization after application launch.
	if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
		NSLog(@"Launched in response to location change update.");
	}
	
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];

    
	// If there is no refresh token present, show the login/signup screen
	if(![[Geoloqi sharedInstance] hasRefreshToken])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationDidSucceed:) 
                                                     name:LQAuthenticationSucceededNotification 
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationDidFail:) 
                                                     name:LQAuthenticationFailedNotification 
                                                   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(unknownAPIError:) 
                                                     name:LQAPIUnknownErrorNotification 
                                                   object:nil];
		
		NSLog(@"Showing welcome view");
		NSLog(@"%@", welcomeViewController);
        [tabBarController presentModalViewController:welcomeViewController animated:YES];
    }
	// else, use the refresh token to get a new access token right now
	else {
		[[Geoloqi sharedInstance] initTokenAndGetUsername];
	}


	UIDevice *d = [UIDevice currentDevice];
	d.batteryMonitoringEnabled = YES;
//	NSLog(@"Name %@, Sys name %@, Sys version %@, Model %@, Idiom %d, Battery %f",
//		  d.name, d.systemName, d.systemVersion, d.model, d.userInterfaceIdiom, d.batteryLevel);

	// TODO: Check for net access here and don't make this request if we're offline
	/*
	NSLog(@"Registering for push notifications");
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];
	*/
	
	// For checking to see what options the app launched with
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:[launchOptions description] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	//[alert show];
	
    return YES;
}

+ (void)initialize {
	[self registerPresetDefaultsFromSettingsBundle];
}

// A cheap way to quit the program after the "error" alert from an HTTP request pops up.
// This will have been called after the user hits "quit" and after the refresh token has already been wiped out.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
	exit(9);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:[userInfo description] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error  {
	NSLog(@"Error: %@", error);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    // Get a hex string from the device token with no spaces or < >
    self.deviceToken = [[[[_deviceToken description]
						  stringByReplacingOccurrencesOfString: @"<" withString: @""] 
						 stringByReplacingOccurrencesOfString: @">" withString: @""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSLog(@"Device Token: %@", self.deviceToken);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token" message:deviceToken delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		NSLog(@"Notifications are disabled for this application. Not registering with Urban Airship");
		return;
	}
	
	// Put the token in someone's server log
	[NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pin13.net?token=%@", deviceToken]] encoding:NSUTF8StringEncoding error:nil];
	
    NSString *UAServer = @"https://go.urbanairship.com";
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", self.deviceToken];
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
	 
    // Authenticate to the server
    [request addValue:[NSString stringWithFormat:@"Basic %@",
                       [GeoloqiAppDelegate base64forData:[[NSString stringWithFormat:@"%@:%@",
                                                        UAApplicationKey,
                                                        UAApplicationSecret] dataUsingEncoding: NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
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
    [super dealloc];
}

#pragma mark -

- (void)authenticationDidSucceed:(NSNotificationCenter *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationSucceededNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationFailedNotification 
                                                  object:nil];
    
    if (tabBarController.modalViewController && [tabBarController.modalViewController isKindOfClass:[welcomeViewController class]])
        [tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)authenticationDidFail:(NSNotificationCenter *)notification
{
	[[SHKActivityIndicator currentIndicator] displayCompleted:@"Error Logging In!"];
	[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✕"];
	
    if (tabBarController.modalViewController && [tabBarController.modalViewController isKindOfClass:[welcomeViewController class]]) {
        [tabBarController.modalViewController dismissModalViewControllerAnimated:YES];
	}
}

- (void)unknownAPIError:(NSNotificationCenter *)notification
{
	[[SHKActivityIndicator currentIndicator] displayCompleted:@"There was an error!"];
	[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✕"];
	
	[tabBarController presentModalViewController:welcomeViewController animated:YES];
	
	[[Geoloqi sharedInstance] logOut];
}

+ (void)registerPresetDefaultsFromSettingsBundle {
	
//	if([[NSUserDefaults standardUserDefaults] objectForKey:@"batteryTrackingLimit"]) {
//		NSLog(@"Slider presets are already saved");
//		return;
//	} else {
//		NSLog(@"Slider presets are not present, loading from plist");
//	}
	
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
	
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Presets.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
			NSLog(@"Will register %@", key);
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"defaultValuesEnteredOnce"]) {
		[[Geoloqi sharedInstance] setDistanceFilterTo:[[defaultsToRegister objectForKey:@"batteryDistanceFilter"] doubleValue]];
		[[Geoloqi sharedInstance] setTrackingFrequencyTo:[[defaultsToRegister objectForKey:@"batteryTrackingLimit"] doubleValue]];
		[[Geoloqi sharedInstance] setSendingFrequencyTo:[[defaultsToRegister objectForKey:@"batteryRateLimit"] doubleValue]];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"defaultValuesEnteredOnce"];
	}
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}

// From: http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

@end
