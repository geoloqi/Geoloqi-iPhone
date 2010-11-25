//
//  GLAuthenticationManager.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GLAuthenticationManager.h"
#import "GLHTTPRequestLoader.h"
#import "CJSONDeserializer.h"
#import "GLConstants.h"

#import "ASIFormDataRequest.h"

static GLAuthenticationManager *sharedManager = nil;

@interface GLAuthenticationManager ()
- (NSString *)encodeParameters:(NSDictionary *)params;
- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
 includeAccessToken:(BOOL)includeAccessToken
  includeClientCred:(BOOL)includeClientCred
		 parameters:(NSDictionary *)params
		   callback:(GLHTTPRequestCallback)callback;
- (GLHTTPRequestCallback)tokenResponseBlock;
- (GLHTTPRequestCallback)initUsernameBlock;
//- (GLHTTPRequestCallback)sharedLinkResponseBlock;
//- (NSString *)refreshToken;
@end

@implementation GLAuthenticationManager

@synthesize accessToken;

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
   includeAccessToken:NO
	includeClientCred:YES
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
   includeAccessToken:NO
	includeClientCred:YES
           parameters:[NSDictionary dictionaryWithObjectsAndKeys:username,    @"username",
                                                                emailAddress, @"email",
                                                                nil]
             callback:[self tokenResponseBlock]];
}

- (void)createAnonymousAccount {
    [self callAPIPath:@"user/create_anon"
               method:@"POST"
   includeAccessToken:NO
	includeClientCred:YES
           parameters:nil
             callback:[self tokenResponseBlock]];
}

// Called when the app first loads if a refresh token is present. Request the user's username
// which will cause a new access token to be fetched as well
- (void)initTokenAndGetUsername {
	[self callAPIPath:@"account/username"
			   method:@"POST"
   includeAccessToken:YES
	includeClientCred:NO
		   parameters:nil
			 callback:[self initUsernameBlock]];
}

/*
- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes
								   withDelegate:(LQShareViewController *)delegate
{
	NSURL *url = [NSURL URLWithString:@"https://api.geoloqi.com/1/link/create"];
	
	NSLog(@"About to make the link/create HTTP request!");

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

	[request setPostValue:minutes forKey:@"minutes"];
	[request setPostValue:accessToken forKey:@"access_token"];
	[request setDelegate:delegate];
	[request startAsynchronous];

	/*
	[self callAPIPath:@"link/create"
			   method:@"POST"
		 authenticate:YES
		   parameters:[NSDictionary dictionaryWithObjectsAndKeys:minutes, @"minutes", nil]
			 callback:callback];
	* /
}
*/

- (void)deauthenticate {
	[accessToken release];
	[tokenExpiryDate release];
	accessToken = nil;
	tokenExpiryDate = nil;

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshAccessTokenWithCallback:(void (^)())callback {
	if (![self refreshToken]) {
		NSLog(@"No refresh token present, can't refresh authorization! :(");
		return;
	}
	if ([tokenExpiryDate timeIntervalSinceNow] > 0) {
		// Token is already valid!
		NSLog(@"Access token is still valid");
		callback();
	} else {
		NSLog(@"Access token expired, refresh the token");
		[self callAPIPath:@"oauth/token"
				   method:@"POST"
	   includeAccessToken:NO
		includeClientCred:YES
			   parameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   @"refresh_token", @"grant_type",
						   [self refreshToken], @"refresh_token", nil]
				 callback:^(NSError *error, NSString *responseBody) {
					 [self tokenResponseBlock](error, responseBody);
					 if (!error) callback();
				 }];
	}
}

/*
 * Not using this right now, see LQShareViewController
- (GLHTTPRequestCallback)sharedLinkResponseBlock {
	if (sharedLinkResponseBlock) return sharedLinkResponseBlock;
	return sharedLinkResponseBlock = [^(NSError *error, NSString *responseBody) {
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res) {
			NSLog(@"Error deserializing response (for link/create) \"%@\": %@", responseBody, err);
			return;
		}
		
		if ([[res objectForKey:@"shortlink"] isKindOfClass:[NSString class]] && [[res objectForKey:@"shortlink"] length])
		{
			NSLog(@"Shared link created %@", [res objectForKey:@"shortlink"]);
			return;
		}
	} copy];
}
 */

- (GLHTTPRequestCallback)tokenResponseBlock {
	// The same method is used to respond to all oauth/token requests.
	if (tokenResponseBlock) return tokenResponseBlock;
	return tokenResponseBlock = [^(NSError *error, NSString *responseBody) {
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for tokenResponseBlock) \"%@\": %@", responseBody, err);
			[self errorProcessingAPIRequest];
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

- (GLHTTPRequestCallback)initUsernameBlock {
	if (initUsernameBlock) return initUsernameBlock;
	return initUsernameBlock = [^(NSError *error, NSString *responseBody) {
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for account/username) \"%@\": %@", responseBody, err);
			[self errorProcessingAPIRequest];
			return;
		}
		
        if ([[res objectForKey:@"username"] isKindOfClass:[NSString class]] && [[res objectForKey:@"username"] length])
        {
            [[NSUserDefaults standardUserDefaults] setObject:[res objectForKey:@"username"] forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
		
		NSLog(@"Got username %@", [res objectForKey:@"username"]);
	} copy];
}


- (BOOL)hasRefreshToken
{
    return ([[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"] != nil
			&& [[[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"] length]);
}

- (NSString *)refreshToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"refreshToken"])
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"refreshToken"];
    
    return nil;
}

- (NSString *)serverURL
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"])
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"serverURL"];
    
	// If they erased the server URL, recreate it from the default value
	[[NSUserDefaults standardUserDefaults] setObject:GL_API_URL forKey:@"serverURL"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    return GL_API_URL;
}

- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
 includeAccessToken:(BOOL)includeAccessToken
  includeClientCred:(BOOL)includeClientCred
		 parameters:(NSDictionary *)params
		   callback:(GLHTTPRequestCallback)callback {
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:
								[[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"]]
								 URLByAppendingPathComponent:path]];
	[req setHTTPMethod:httpMethod];
	
	NSLog([NSString stringWithFormat:@"Calling API Method %@", path]);
	
	NSMutableDictionary *fullParams = [NSMutableDictionary dictionaryWithDictionary:params];

	if (includeClientCred) {
		NSLog(@"Adding client credentials to request");
		// Add the client id/secret for API authorization
		[fullParams setObject:GL_OAUTH_CLIENT_ID forKey:@"client_id"];
		[fullParams setObject:GL_OAUTH_SECRET    forKey:@"client_secret"];
	}
	
	[req setHTTPBody:[[self encodeParameters:fullParams]
					  dataUsingEncoding:NSUTF8StringEncoding]];

	if (includeAccessToken) {
		[self refreshAccessTokenWithCallback:^{
					[req setValue:[NSString stringWithFormat:@"OAuth %@", accessToken]
			   forHTTPHeaderField:@"Authorization"];
			NSLog(@"About to run the HTTP request with OAuth %@! Params: %@", accessToken, [self encodeParameters:fullParams]);
			[GLHTTPRequestLoader loadRequest:req
									callback:callback];
		}];
	} else {
		NSLog(@"About to run the HTTP request with no OAuth header. Params: %@", [self encodeParameters:fullParams]);
		[GLHTTPRequestLoader loadRequest:req
								callback:callback];
	}
}

- (void)errorProcessingAPIRequest {
	// There was a problem with the response from the API. Bail out!
	// This is totally not an ideal solution, but it's better than the app looking like nothing went wrong or also hanging.
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"There was a problem! Try logging in again."
												   delegate:gAppDelegate
										  cancelButtonTitle:@"Quit" 
										  otherButtonTitles:nil];
	[alert show];
	
	// Wipe out the stored refresh token since it won't be any good anymore
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshToken"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[accessToken release];
	[tokenExpiryDate release];
	[alert release];
}

- (void)dealloc {
	[accessToken release];
	[tokenExpiryDate release];
	[tokenResponseBlock release];
	[super dealloc];
}


@end
