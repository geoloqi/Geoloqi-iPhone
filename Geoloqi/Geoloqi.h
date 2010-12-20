/*
 *  Geoloqi.h
 *  Geoloqi API 
 *
 *  Copyright 2010 Geoloqi.com. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static NSString *const LQLocationUpdateManagerDidUpdateLocationNotification = @"LQLocationUpdateManagerDidUpdateLocationNotification";
static NSString *const LQLocationUpdateManagerStartedSendingLocations = @"LQLocationUpdateManagerStartedSendingLocations";
static NSString *const LQLocationUpdateManagerFinishedSendingLocations = @"LQLocationUpdateManagerFinishedSendingLocations";
static NSString *const LQLocationUpdateManagerFinishedSendingSingleLocation = @"LQLocationUpdateManagerFinishedSendingSingleLocation";
static NSString *const LQLocationUpdateManagerErrorSendingSingleLocation = @"LQLocationUpdateManagerErrorSendingSingleLocation";
static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";
static NSString *const LQAuthenticationFailedNotification = @"LQAuthenticationFailedNotification";
static NSString *const LQAPIUnknownErrorNotification = @"LQAPIUnknownErrorNotification";

enum {
	LQPresetBattery = 0,
	LQPresetRealtime
};

typedef void (^LQHTTPRequestCallback)(NSError *error, NSString *responseBody);


@interface Geoloqi : NSObject 
{
}

+ (Geoloqi *) sharedInstance;

#pragma mark Application

- (void)createGeonote:(NSString *)text latitude:(float)latitude longitude:(float)longitude radius:(float)radius callback:(LQHTTPRequestCallback)callback;

- (void)createLink:(NSString *)description minutes:(NSInteger)minutes callback:(LQHTTPRequestCallback)callback;

- (void)layerAppList:(LQHTTPRequestCallback)callback;

- (void)subscribeToLayer:(NSString *)layerID callback:(LQHTTPRequestCallback)callback;
- (void)unSubscribeFromLayer:(NSString *)layerID callback:(LQHTTPRequestCallback)callback;

#pragma mark Location

- (void)singleLocationUpdate;

- (void)startOrStopMonitoringLocationIfNecessary;
- (void)startLocationUpdates;
- (void)stopLocationUpdates;
- (void)setDistanceFilterTo:(CLLocationDistance)distance;
- (void)setTrackingFrequencyTo:(NSTimeInterval)frequency;
- (void)setSendingFrequencyTo:(NSTimeInterval)frequency;

- (NSDate *)lastLocationDate;
- (NSDate *)lastUpdateDate;
- (CLLocation *)currentSingleLocation;
- (CLLocation *)currentLocation;
- (BOOL)locationUpdatesState;
- (CLLocationDistance)distanceFilterDistance;
- (NSTimeInterval)trackingFrequency;
- (NSTimeInterval)sendingFrequency;
- (NSUInteger)locationQueueCount;

- (void)loadHistory:(NSDictionary *)params callback:(LQHTTPRequestCallback)callback;
- (void)sendLocationData:(NSMutableArray *)points callback:(LQHTTPRequestCallback)callback;
- (void)sendQueuedPoints;
- (NSDictionary *)dictionaryFromLocation:(CLLocation *)location;

#pragma mark Authentication

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;
- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;
- (void)createAnonymousAccount;
- (void)createAnonymousAccount:(NSString*)name;

- (void)initTokenAndGetUsername;

#pragma mark Invitation

- (void)createInvitation:(LQHTTPRequestCallback)callback;

- (void)getInvitationAtHost:(NSString *)host token:(NSString *)invitationToken callback:(LQHTTPRequestCallback)callback;

- (void)claimInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;

- (void)confirmInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;

- (void)getAccessTokenForInvitation:(NSString*)invitationToken callback:(LQHTTPRequestCallback)callback;

#pragma mark -

- (void)setOauthClientID:(NSString*)clientID secret:(NSString*)secret;

- (void)setOauthAccessToken:(NSString *)accessToken;

- (void)errorProcessingAPIRequest;

- (NSString *)refreshToken;

- (NSString *)accessToken;

- (NSString *)serverURL;

- (BOOL)hasRefreshToken;

- (void)logOut;

- (NSString *)hardware;

@end
