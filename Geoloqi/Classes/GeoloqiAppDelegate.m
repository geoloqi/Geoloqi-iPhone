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
#import "SHKActivityIndicator.h"
#import "LQBatteryMonitor.h"
#import "Reachability.h"

GeoloqiAppDelegate *gAppDelegate;

@implementation GeoloqiAppDelegate

@synthesize deviceToken;
@synthesize window, welcomeViewController;
@synthesize tabBarController;
@synthesize pushHandler;
@synthesize lqBtnImg, lqBtnDisabledImg, lqBtnLightDisabledImg;
@synthesize signInEmailAddress;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	gAppDelegate = self;
	
	self.lqBtnImg = [[UIImage imageNamed:@"LQButton.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
	self.lqBtnDisabledImg = [[UIImage imageNamed:@"LQButtonDisabled.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
	self.lqBtnLightDisabledImg = [[UIImage imageNamed:@"LQButtonLightDisabled.png"] stretchableImageWithLeftCapWidth:9.f topCapHeight:9.f];
	
	pushHandler = [[LQPushHandler alloc] myInit];

	[[Geoloqi sharedInstance] setUserAgentString:LQ_USER_AGENT];
	
	// IMPORTANT: Set up OAuth prior to making network calls to the geoloqi server.
    [[Geoloqi sharedInstance] setOauthClientID:LQ_OAUTH_CLIENT_ID secret:LQ_OAUTH_SECRET];

    // Override point for customization after application launch.
	if (launchOptions) {
		NSLog(@"Launched with options %@", launchOptions);
	}
	
	// Starts location updates if the last state of the app had updates turned on
	[[Geoloqi sharedInstance] startOrStopMonitoringLocationIfNecessary];
	
	// TODO: Investigate if this needs to be not done if restoring in background after signficant update
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    
	// If there is no refresh token present, show the login/signup screen
	if(![[Geoloqi sharedInstance] hasRefreshToken])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationDidSucceed:) 
                                                     name:LQAuthenticationSucceededNotification 
                                                   object:nil];

        [tabBarController presentModalViewController:welcomeViewController animated:YES];
    }
	// else, use the refresh token to get a new access token right now
	else {
		[[Geoloqi sharedInstance] initTokenAndGetUsername];

		NSLog(@"Registering for push notifications");
		[[UIApplication sharedApplication]
		 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
											 UIRemoteNotificationTypeSound |
											 UIRemoteNotificationTypeAlert)];

		// If the app was launched from a push notification, handle that here
		if(launchOptions){
			[pushHandler handleLaunch:launchOptions];
		}
		
	}

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(unknownAPIError:) 
												 name:LQAPIUnknownErrorNotification 
											   object:nil];
	
	// Listen for the "Log Out" notification, which is sent by the API when there is an unrecoverable error
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(logOut) 
												 name:LQAuthenticationLogoutNotification
											   object:nil];

	// Listen for the "Stopped Tracking" notification which is used to cancel any pending shutoff notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(cancelShutdownNotifications) 
												 name:LQTrackingStoppedNotification
											   object:nil];
    //__dbhan:  Added the reachability notifications here as
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNetworkChange:)
                                                 name:kReachabilityChangedNotification 
                                               object:nil]; */
//__dbhan: Needed ?//socketReadReachability = [[Reachability reachabilityForInternetConnection] retain];
//__dbhan: Needed ? [socketReadReachability startNotifier];
	[[LQBatteryMonitor sharedInstance] start];	//__dbhan till here..
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
	NSLog(@"Received Push! %@", userInfo);

	[self.pushHandler handlePush:application notification:userInfo];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton. Sent when the app is in the foreground, but also when the app launches in response to a notification.
	[self.pushHandler handleLocalNotificationFromApp:app notif:notif];
}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error  {
	NSLog(@"Error Registering for Push Notifications! %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken {
    // Get a hex string from the device token with no spaces or < >
    self.deviceToken = [[[[_deviceToken description]
						  stringByReplacingOccurrencesOfString: @"<" withString: @""] 
						 stringByReplacingOccurrencesOfString: @">" withString: @""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSLog(@"Device Token: %@", self.deviceToken);
	
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
		NSLog(@"Notifications are disabled for this application. Not registering.");
		return;
	}
	
	// Send the token to Geoloqi
	[[Geoloqi sharedInstance] sendAPNDeviceToken:self.deviceToken developmentMode:@"0" callback:^(NSError *error, NSString *responseBody){
		//NSLog(@"Sent device token: %@", responseBody);
	}];
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
     TODO: Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	NSLog(@"Received memory warning");
}


- (void)dealloc {
	[lqBtnImg release];
	[pushHandler release];
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

	// Register for push notifications after logging in successfully
	NSLog(@"Registering for push notifications");
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];
//__dbhan: Add the device registeration code here ... Make a new call to setDevice call .... 
}


- (void)sendAPNDeviceToken:(NSString *)deviceToken developmentMode:(NSString *)devMode callback:(LQHTTPRequestCallback)callback {
    UIDevice *d = [UIDevice currentDevice];
    
    [self.authManager callAPIPath:@"account/set_apn_token"
                           method:@"POST"
               includeAccessToken:YES 
                includeClientCred:NO
                       parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                   deviceToken, @"token",
                                   d.uniqueIdentifier, @"device_id",
                                   devMode, @"dev",
                                   [NSString stringWithFormat:@"%@ %@", d.systemName, d.systemVersion], @"platform",
                                   [self hardware], @"hardware",
                                   nil]
                         callback:callback];
}

- (void)unknownAPIError:(NSNotificationCenter *)notification
{
	Reachability *reachability = [Reachability reachabilityWithHostName:@"api.geoloqi.com"];
	if([reachability currentReachabilityStatus] > 0) {
		// Can reach the server, so something is wrong
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Network issues!"];
		[[SHKActivityIndicator currentIndicator] setCenterMessage:@"☁"];
 	} else {
		// Can't reach the server, probably in airplane mode
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Can't find network!"];
		[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✈"];
	}
	
// 	[[Geoloqi sharedInstance] logOut];
}

- (void)logOut {
	[[SHKActivityIndicator currentIndicator] displayCompleted:@"Logged Out!"];
	[tabBarController presentModalViewController:welcomeViewController animated:YES];
	[[Geoloqi sharedInstance] logOut];

	exit(0);
}

+ (void)userIsAnonymous {
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_anonymous"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)userIsNotAnonymous {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"is_anonymous"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isUserAnonymous {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"is_anonymous"];
}

- (void)makeLQButton:(UIButton *)btn {
	[btn setBackgroundImage:self.lqBtnImg forState:UIControlStateNormal];
	[btn setBackgroundImage:self.lqBtnDisabledImg forState:UIControlStateDisabled];
	[btn.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn setTitleShadowColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.5 alpha:1.0] forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0] forState:UIControlStateDisabled];
	[btn setTitleShadowColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.2 alpha:1.0] forState:UIControlStateDisabled];
}

- (void)makeLQButtonLight:(UIButton *)btn {
	[btn setBackgroundImage:self.lqBtnImg forState:UIControlStateNormal];
	[btn setBackgroundImage:self.lqBtnLightDisabledImg forState:UIControlStateDisabled];
	[btn.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn setTitleShadowColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.5 alpha:1.0] forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.5 alpha:1.0] forState:UIControlStateDisabled];
	[btn setTitleShadowColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.4 alpha:0.0] forState:UIControlStateDisabled];
}

- (void)cancelShutdownNotifications {
	[[Geoloqi sharedInstance] cancelShutdownTimers];
}

+ (void)registerPresetDefaultsFromSettingsBundle 
{
	
//	if([[NSUserDefaults standardUserDefaults] objectForKey:@"batteryTrackingLimit"]) {
//		NSLog(@"Slider presets are already saved");
//		return;
//	} else {
//		NSLog(@"Slider presets are not present, loading from plist");
//	}
	
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) 
    {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
	
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Presets.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) 
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) 
        {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [defaultsToRegister setObject:@"NO" forKey:LQLocationUpdateManagerSendingMethodDefaultKey]; // __dbhan: NO = OFF = HTTP ;; YES = ON = UDP
    [[Geoloqi sharedInstance] setSendingMethodTo:LQSendingMethodHTTP]; //__dbhan  // start mode = Battery safe mode or passive mode      
    [[Geoloqi sharedInstance] setLocationUpdatesOnTo:YES]; //__dbhan => Battery safe mode + location updates automatically on.
    if (1)
    {
        [[Geoloqi sharedInstance] setDistanceFilterTo:[[defaultsToRegister objectForKey:@"batteryDistanceFilter"] doubleValue]];
		[[Geoloqi sharedInstance] setTrackingFrequencyTo:[[defaultsToRegister objectForKey:@"batteryTrackingLimit"] doubleValue]];
		[[Geoloqi sharedInstance] setSendingFrequencyTo:[[defaultsToRegister objectForKey:@"batteryRateLimit"] doubleValue]];
    }
    /*if (![[NSUserDefaults standardUserDefaults] boolForKey:@"defaultValuesEnteredOnce"]) 
    {
		[[Geoloqi sharedInstance] setDistanceFilterTo:[[defaultsToRegister objectForKey:@"batteryDistanceFilter"] doubleValue]];
		[[Geoloqi sharedInstance] setTrackingFrequencyTo:[[defaultsToRegister objectForKey:@"batteryTrackingLimit"] doubleValue]];
		[[Geoloqi sharedInstance] setSendingFrequencyTo:[[defaultsToRegister objectForKey:@"batteryRateLimit"] doubleValue]];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"defaultValuesEnteredOnce"];
	}*/
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
#if (VERBOSE)
    NSLog(@"defaultsToRegister is = %@", defaultsToRegister);
#endif
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
