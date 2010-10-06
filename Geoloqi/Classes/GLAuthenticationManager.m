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

static GLAuthenticationManager *sharedManager = nil;

@interface GLAuthenticationManager ()
- (NSString *)encodeParameters:(NSDictionary *)params;
- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
	   authenticate:(BOOL)needsAuth
		 parameters:(NSDictionary *)params
		   callback:(GLHTTPRequestCallback)callback;
- (GLHTTPRequestCallback)tokenResponseBlock;
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

- (void)deauthenticate {
	[accessToken release];
	[tokenExpiryDate release];
	[refreshToken release];
	accessToken = nil;
	tokenExpiryDate = nil;
	refreshToken = nil;
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
						   refreshToken, @"refresh_token", nil]
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
		[refreshToken release];
		
		accessToken = [[res objectForKey:@"access_token"] copy];
		tokenExpiryDate = [[[NSDate date] dateByAddingTimeInterval:
							[[res objectForKey:@"expires_in"] doubleValue]] retain];
		refreshToken = [[res objectForKey:@"refresh_token"] copy];
		
		NSLog(@"Got access token %@, expires %@, refresh %@", accessToken, tokenExpiryDate, refreshToken);
	} copy];
}

- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
	   authenticate:(BOOL)needsAuth
		 parameters:(NSDictionary *)params
		   callback:(GLHTTPRequestCallback)callback {
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:
								[[NSURL URLWithString:@"https://api.geoloqi.com/1/"]
								 URLByAppendingPathComponent:path]];
	[req setHTTPMethod:httpMethod];
	
	// Add the client id/secret for API authorization
	NSMutableDictionary *fullParams = [NSMutableDictionary dictionaryWithDictionary:params];
	[fullParams setObject:@"jtbandes_iphone" forKey:@"client_id"];
	[fullParams setObject:@"bdbe49daf6784457938671116426124R" forKey:@"client_secret"];
	
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
	[refreshToken release];
	[tokenResponseBlock release];
	[super dealloc];
}


@end
