//
//  GeoloqiAppDelegate.h
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
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
