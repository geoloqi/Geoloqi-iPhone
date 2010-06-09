//
//  LocationUpdaterAppDelegate.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocationUpdateManager.h"

@class LocationUpdaterViewController;


@interface LocationUpdaterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LocationUpdaterViewController *viewController;
	LocationUpdateManager *locationUpdateManager;
}

@property (nonatomic, retain) LocationUpdateManager *locationUpdateManager;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LocationUpdaterViewController *viewController;

@end

extern LocationUpdaterAppDelegate *gAppDelegate;
