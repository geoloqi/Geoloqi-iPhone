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
	NSDate *tokenExpiryDate;
	GLHTTPRequestCallback tokenResponseBlock;
	GLHTTPRequestCallback initUsernameBlock;
	//GLHTTPRequestCallback sharedLinkResponseBlock;
}

@property (nonatomic, retain) NSString *accessToken;

+ (GLAuthenticationManager *)sharedManager;

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;
- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;
- (void)createAnonymousAccount;

- (void)initTokenAndGetUsername;

- (void)errorProcessingAPIRequest;

//- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes
//								   withDelegate:(LQShareViewController *)delegate;

- (NSString *)refreshToken;
- (NSString *)serverURL;
- (BOOL)hasRefreshToken;

@end

