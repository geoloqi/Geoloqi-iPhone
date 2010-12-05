/*
 *  Geoloqi.h
 *  Geoloqi API 
 *
 *  Copyright 2010 Geoloqi.com. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GL_OAUTH_CLIENT_ID	@"1"
#define GL_OAUTH_SECRET		@"1"

static NSString *const GLAuthenticationSucceededNotification = @"GLAuthenticationSucceededNotification";

NSString *const GLLocationUpdateManagerDidUpdateLocationNotification;

typedef void (^GLHTTPRequestCallback)(NSError *error, NSString *responseBody);


@interface Geoloqi : NSObject 
{
}

+ (Geoloqi *) sharedInstance;

#pragma mark Application

- (void)createGeonote:(NSString *)text latitude:(float)latitude longitude:(float)longitude radius:(float)radius callback:(GLHTTPRequestCallback)callback;

- (void)createLink:(NSString *)description minutes:(NSInteger)minutes callback:(GLHTTPRequestCallback)callback;

- (void)layerAppList:(GLHTTPRequestCallback)callback;

- (void)subscribeToLayer:(NSString *)layerID callback:(GLHTTPRequestCallback)callback;

#pragma mark Location

- (void)startOrStopMonitoringLocationIfNecessary;
- (void)setLocationUpdatesTo:(BOOL)state;
- (void)setDistanceFilterTo:(CLLocationDistance)distance;
- (void)setTrackingFrequencyTo:(NSTimeInterval)frequency;
- (void)setSendingFrequencyTo:(NSTimeInterval)frequency;

- (CLLocation *)currentLocation;
- (BOOL)locationUpdatesState;
- (CLLocationDistance)distanceFilterDistance;
- (NSTimeInterval)trackingFrequency;
- (NSTimeInterval)sendingFrequency;
- (NSUInteger)locationQueueCount;

#pragma mark Authentication

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;
- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;
- (void)createAnonymousAccount;
- (void)createAnonymousAccount:(NSString*)name;

- (void)initTokenAndGetUsername;

#pragma mark Invitation

- (void)createInvitation:(GLHTTPRequestCallback)callback;

- (void)getInvitationAtHost:(NSString *)host token:(NSString *)invitationToken callback:(GLHTTPRequestCallback)callback;

- (void)claimInvitation:(NSString*)invitationToken host:(NSString*)host callback:(GLHTTPRequestCallback)callback;

- (void)confirmInvitation:(NSString*)invitationToken host:(NSString*)host callback:(GLHTTPRequestCallback)callback;

- (void)getAccessTokenForInvitation:(NSString*)invitationToken callback:(GLHTTPRequestCallback)callback;

#pragma mark -

- (void)setOauthClientID:(NSString*)clientID secret:(NSString*)secret;

- (void)setOauthAccessToken:(NSString *)accessToken;

- (void)errorProcessingAPIRequest;

- (NSString *)refreshToken;

- (NSString *)serverURL;

- (BOOL)hasRefreshToken;


@end
