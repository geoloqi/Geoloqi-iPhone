//
//  GeoloqiAppDelegate.h
//  Geoloqi
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQPushHandler.h"

//Forward declaration for the Geoloqisocket read/write clients
@class GeoloqiSocketClient;
@class GeoloqiReadClient;
@class Reachability;


@interface GeoloqiAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	NSString *deviceToken;
	LQPushHandler *pushHandler;
	UIImage *lqBtnImg, *lqBtnDisabledImg, *lqBtnLightDisabledImg;
    //Reachability *socketReadReachability;          // __dbhan: Do i need this => No ..
}

@property (nonatomic, retain) IBOutlet UIViewController *welcomeViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString *deviceToken;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) LQPushHandler *pushHandler;
@property (nonatomic, retain) UIImage *lqBtnImg, *lqBtnDisabledImg, *lqBtnLightDisabledImg;
@property (nonatomic, retain) NSString *signInEmailAddress;

+ (void)userIsAnonymous;
+ (void)userIsNotAnonymous;
+ (BOOL)isUserAnonymous;
+ (void)registerPresetDefaultsFromSettingsBundle;
+ (NSString*)base64forData:(NSData*)theData;
- (void)makeLQButton:(UIButton *)btn;
- (void)makeLQButtonLight:(UIButton *)btn;
- (void)cancelShutdownNotifications;
- (void)logOut;

@end

extern GeoloqiAppDelegate *gAppDelegate;
