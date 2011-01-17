//
//  LQShareService.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareService.h"


@implementation LQShareService

@synthesize controller;

- (LQShareService *)initWithController:(UIViewController *)_controller {
    if (self = [super init]) {
		self.controller = _controller;
    }
    return self;
}

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message {
	NSLog(@"TODO: Implement this method in the child class to perform the appropriate share function.");
}

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message canPost:(BOOL)canPost {
	NSLog(@"TODO: Implement this method in the child class to perform the appropriate share function.");
}

- (void)presentModalViewController:(UIViewController *)_controller {
	[self.controller presentModalViewController:_controller animated:YES];
}

- (void)shareControllerDidFinish {
	[self.controller.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)shareControllerDidCancel:(UIViewController *)_controller {
	[_controller dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[controller dealloc];
	[super dealloc];
}

@end
