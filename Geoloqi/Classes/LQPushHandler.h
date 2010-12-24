//
//  LQPushHandler.h
//  Geoloqi
//
//  Created by Aaron Parecki on 12/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
	kLQPushAlertGeonote = 0,
	kLQPushAlertShutdown,
	kLQPushAlertStart
};

@interface LQPushHandler : NSObject <UIAlertViewDelegate> {

}

- (void)handlePush:(NSDictionary *)userInfo;
- (void)handleLaunch:(NSDictionary *)launchOptions;

@end
