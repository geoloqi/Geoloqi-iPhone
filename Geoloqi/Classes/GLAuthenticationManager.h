//
//  GLAuthenticationManager.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLHTTPRequestLoader.h"

@interface GLAuthenticationManager : NSObject {
	NSString *accessToken;
	NSDate *tokenExpiryDate;
	NSString *refreshToken;
	GLHTTPRequestCallback tokenResponseBlock;
}

+ (GLAuthenticationManager *)sharedManager;

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;

@end
