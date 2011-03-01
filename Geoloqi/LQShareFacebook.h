/*
//
//  LQShareFacebook.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LQShareService.h"
#import "LQShareFacebookViewController.h"

@interface LQShareFacebook : LQShareService <LQShareFacebookDelegate> {
	LQShareFacebookViewController *shareView;
	LQHTTPRequestCallback postedCallback;
}

@property (nonatomic, retain) LQShareFacebookViewController *shareView;

- (LQHTTPRequestCallback)postedCallback;

@end
*/