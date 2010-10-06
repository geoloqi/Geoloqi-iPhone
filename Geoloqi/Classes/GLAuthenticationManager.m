//
//  GLAuthenticationManager.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import "GLAuthenticationManager.h"
#import "GLHTTPRequestLoader.h"
#import "CJSONDeserializer.h"
#import "GLConstants.h"

static GLAuthenticationManager *sharedManager = nil;

@interface GLAuthenticationManager ()
- (NSString *)encodeParameters:(NSDictionary *)params;
- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
	   authenticate:(BOOL)needsAuth
		 parameters:(NSDictionary *)params
		   callback:(GLHTTPRequestCallback)callback;
- (GLHTTPRequestCallback)tokenResponseBlock;
- (NSString *)refreshToken;
@end


@implementation GLAuthenticationManager

+ (GLAuthenticationManager *)sharedManager {
	if (!sharedManager) {
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

- (NSString *)encodeParameters:(NSDictionary *)params {
	if (!params) return nil;
	
	NSMutableArray *keyvals = [NSMutableArray array];
	for (NSString *key in params) {
		[keyvals addObject:
		 [NSString stringWithFormat:@"%@=%@",
		  [(id)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)key,
													   NULL, CFSTR("&="), kCFStringEncodingUTF8) autorelease],
		  [(id)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[params objectForKey:key],
													   NULL, CFSTR("&"), kCFStringEncodingUTF8) autorelease]]];
	}
	return [keyvals componentsJoinedByString:@"&"];
}

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password {
	[self callAPIPath:@"oauth/token"
			   method:@"POST"
		 authenticate:NO
		   parameters:[NSDictionary dictionaryWithObjectsAndKeys:
					   @"password", @"grant_type",
					   username, @"username",
					   password, @"password", nil]
			 callback:[self tokenResponseBlock]];
}

- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress
{
    [self callAPIPath:@"user/create"
               method:@"POST"
         authenticate:NO
           parameters:[NSDictionary dictionaryWithObjectsAndKeys:username,    @"username",
                                                                emailAddress, @"email",
                                                                nil]
             callback:[self tokenResponseBlock]];
}

- (void)deauthenticate {
	[accessToken release];
	[tokenExpiryDate release];
	accessToken = nil;
	tokenExpiryDate = nil;

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshAccessTokenWithCallback:(void (^)())callback {
	if (!accessToken) {
		NSLog(@"No access token loaded, can't refresh authorization! :(");
		return;
	}
	if ([tokenExpiryDate timeIntervalSinceNow] > 0) {
		// Token is already valid!
		callback();
	} else {
		[self callAPIPath:@"oauth/token"
				   method:@"POST"
			 authenticate:NO
			   parameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   @"refresh", @"grant_type",
						   [self refreshToken], @"refresh_token", nil]
				 callback:^(NSError *error, NSString *responseBody) {
					 [self tokenResponseBlock](error, responseBody);
					 if (!error) callback();
				 }];
	}
}

- (GLHTTPRequestCallback)tokenResponseBlock {
	// The same method is used to respond to all oauth/token requests.
	if (tokenResponseBlock) return tokenResponseBlock;
	return tokenResponseBlock = [^(NSError *error, NSString *responseBody) {
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res) {
			NSLog(@"Error deserializing response (for oauth/token) \"%@\": %@", responseBody, err);
			return;
		}
		
		[accessToken release];
		[tokenExpiryDate release];
		
		accessToken = [[res objectForKey:@"access_token"] copy];
		tokenExpiryDate = [[[NSDate date] dateByAddingTimeInterval:
							[[res objectForKey:@"expires_in"] doubleValue]] retain];
        
        if ([[res objectForKey:@"refresh_token"] isKindOfClass:[NSString class]] && [[res objectForKey:@"refresh_token"] length])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[res objectForKey:@"refresh_token"] forKey:@"refreshToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSNotificationCenter defaultCenter] postNotificationName:GLAuthenticationSucceededNotification object:self];
        }
		
		NSLog(@"Got access token %@, expires %@, refresh %@", accessToken, tokenExpiryDate, [self refreshToken]);
	} copy];
}

- (BOOL)hasRefreshToken
{
    return ([[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"] != nil);
}

- (NSString *)refreshToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"])
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"refreshToken"];
    
    return nil;
}

- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
	   authenticate:(BOOL)needsAuth
		 parameters:(NSDictionary *)params
		   callback:(GLHTTPRequestCallback)callback {
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:
								[[NSURL URLWithString:GL_API_URL]
								 URLByAppendingPathComponent:path]];
	[req setHTTPMethod:httpMethod];
	
	// Add the client id/secret for API authorization
	NSMutableDictionary *fullParams = [NSMutableDictionary dictionaryWithDictionary:params];
	[fullParams setObject:GL_OAUTH_CLIENT_ID forKey:@"client_id"];
	[fullParams setObject:GL_OAUTH_SECRET    forKey:@"client_secret"];
	
	[req setHTTPBody:[[self encodeParameters:fullParams]
					  dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (needsAuth) {
		[self refreshAccessTokenWithCallback:^{
			[req setValue:[NSString stringWithFormat:@"OAuth %@", accessToken]
	   forHTTPHeaderField:@"Authorization"];
			[GLHTTPRequestLoader loadRequest:req
									callback:callback];
		}];
	} else {
		[GLHTTPRequestLoader loadRequest:req
								callback:callback];
	}
}

- (void)dealloc {
	[accessToken release];
	[tokenExpiryDate release];
	[tokenResponseBlock release];
	[super dealloc];
}


@end
