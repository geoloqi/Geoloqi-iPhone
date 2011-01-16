//
//  LQShareService.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

@protocol LQShareService

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message fromController:(UIViewController *)controller;

@end
