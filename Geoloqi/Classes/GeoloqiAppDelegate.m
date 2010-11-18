//
//  GeoloqiAppDelegate.m
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GLConstants.h"
#import "GeoloqiAppDelegate.h"
#import "LocationUpdaterViewController.h"
#import "GLAuthenticationManager.h"

GeoloqiAppDelegate *gAppDelegate;

@implementation GeoloqiAppDelegate

@synthesize locationUpdateManager;
@synthesize deviceToken;
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
/*
    if ( ! [[GLAuthenticationManager sharedManager] hasRefreshToken]) // we haven't logged in before
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationDidSucceed:) 
                                                     name:GLAuthenticationSucceededNotification 
                                                   object:nil];

        [tabBarController presentModalViewController:welcomeViewController animated:YES];
    }
*/
	UIDevice *d = [UIDevice currentDevice];
	d.batteryMonitoringEnabled = YES;
//	NSLog(@"Name %@, Sys name %@, Sys version %@, Model %@, Idiom %d, Battery %f",
//		  d.name, d.systemName, d.systemVersion, d.model, d.userInterfaceIdiom, d.batteryLevel);

	NSLog(@"Registering for push notifications");
	[[UIApplication sharedApplication]
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
										 UIRemoteNotificationTypeSound |
										 UIRemoteNotificationTypeAlert)];
	
	
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:[launchOptions description] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	//[alert show];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:[userInfo description] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[alert show];
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
                                                        kApplicationKey,
                                                        kApplicationSecret] dataUsingEncoding: NSUTF8StringEncoding]]] forHTTPHeaderField:@"Authorization"];
    
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
