//
//  GLAuthenticationManager.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLHTTPRequestLoader.h"

#import "LQShareViewController.h"

static NSString *const GLAuthenticationSucceededNotification = @"GLAuthenticationSucceededNotification";

@interface GLAuthenticationManager : NSObject {
	NSString *accessToken;
	NSDate *tokenExpiryDate;
	GLHTTPRequestCallback tokenResponseBlock;
	//GLHTTPRequestCallback sharedLinkResponseBlock;
}

+ (GLAuthenticationManager *)sharedManager;

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;
- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;
//- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes
//								   withDelegate:(LQShareViewController *)delegate;

- (NSString *)accessToken;
- (NSString *)refreshToken;
- (NSString *)serverURL;
- (BOOL)hasRefreshToken;

@end

