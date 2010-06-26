//
//  LocationUpdaterAppDelegate.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocationUpdateManager.h"



@interface LocationUpdaterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	LocationUpdateManager *locationUpdateManager;
}

@property (nonatomic, retain) LocationUpdateManager *locationUpdateManager;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end

extern LocationUpdaterAppDelegate *gAppDelegate;
