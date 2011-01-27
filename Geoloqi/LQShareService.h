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
	NSNumber *minutes;
}

@property (nonatomic, retain) UIViewController *controller;
@property (nonatomic, retain) NSNumber *minutes;

+ (void)linkWasSent:(NSString *)verb minutes:(NSNumber *)_minutes;

- (LQShareService *)initWithController:(UIViewController *)_controller;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes canPost:(BOOL)canPost;

- (void)presentModalViewController:(UIViewController *)_controller;

- (void)shareControllerDidFinish;

- (void)shareControllerDidCancel:(UIViewController *)_controller;

@end
