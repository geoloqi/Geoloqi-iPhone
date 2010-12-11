//
//  GeoloqiAppDelegate.h
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeoloqiAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	NSString *deviceToken;
}

@property (nonatomic, retain) IBOutlet UIViewController *welcomeViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

+ (NSString*)base64forData:(NSData*)theData;

@end

extern GeoloqiAppDelegate *gAppDelegate;
