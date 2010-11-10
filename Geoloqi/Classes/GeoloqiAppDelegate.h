//
//  LocationUpdaterAppDelegate.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GLLocationUpdateManager.h"

@interface GeoloqiAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	GLLocationUpdateManager *locationUpdateManager;
	NSString *deviceToken;
	
	
}

@property (nonatomic, retain) IBOutlet UIViewController *welcomeViewController;
@property (nonatomic, retain) GLLocationUpdateManager *locationUpdateManager;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *deviceToken;

+ (NSString*)base64forData:(NSData*)theData;

@end

extern GeoloqiAppDelegate *gAppDelegate;
