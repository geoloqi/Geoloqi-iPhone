//
//  LQShareService.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LQShareService : NSObject {
	UIViewController *controller;
}

@property (nonatomic, retain) UIViewController *controller;

+ (void)linkWasSent:(NSString *)verb;

- (LQShareService *)initWithController:(UIViewController *)_controller;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message canPost:(BOOL)canPost;

- (void)presentModalViewController:(UIViewController *)_controller;

- (void)shareControllerDidFinish;

- (void)shareControllerDidCancel:(UIViewController *)_controller;

@end
