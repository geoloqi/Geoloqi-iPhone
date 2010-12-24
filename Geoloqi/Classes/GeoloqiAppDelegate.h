//
//  GeoloqiAppDelegate.h
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQPushHandler.h"

@interface GeoloqiAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	NSString *deviceToken;
	LQPushHandler *pushHandler;
}

@property (nonatomic, retain) IBOutlet UIViewController *welcomeViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) LQPushHandler *pushHandler;

+ (void)registerPresetDefaultsFromSettingsBundle;
+ (NSString*)base64forData:(NSData*)theData;

@end

extern GeoloqiAppDelegate *gAppDelegate;
