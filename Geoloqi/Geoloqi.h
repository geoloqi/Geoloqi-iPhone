/*
 *  Geoloqi.h
 *  Geoloqi API 
 *
 *  Copyright 2010 Geoloqi.com. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "DebugLog.h"


#define VERBOSE 1

static NSString *const LQLocationUpdateManagerDidUpdateLocationNotification = @"LQLocationUpdateManagerDidUpdateLocationNotification";
static NSString *const LQLocationUpdateManagerDidUpdateSingleLocationNotification = @"LQLocationUpdateManagerDidUpdateSingleLocationNotification";
static NSString *const LQLocationUpdateManagerDidUpdateFriendLocationNotification = @"LQLocationUpdateManagerDidUpdateFriendLocationNotification";
static NSString *const LQLocationUpdateManagerStartedSendingLocations = @"LQLocationUpdateManagerStartedSendingLocations";
static NSString *const LQLocationUpdateManagerFinishedSendingLocations = @"LQLocationUpdateManagerFinishedSendingLocations";
static NSString *const LQLocationUpdateManagerFinishedSendingSingleLocation = @"LQLocationUpdateManagerFinishedSendingSingleLocation";
static NSString *const LQLocationUpdateManagerErrorSendingSingleLocation = @"LQLocationUpdateManagerErrorSendingSingleLocation";
static NSString *const LQTrackingStoppedNotification = @"LQTrackingStoppedNotification";
static NSString *const LQTrackingStartedNotification = @"LQTrackingStartedNotification";
static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";
static NSString *const LQAuthenticationFailedNotification = @"LQAuthenticationFailedNotification";
static NSString *const LQAuthenticationLogoutNotification = @"LQAuthenticationLogoutNotification";
static NSString *const LQAnonymousSignupSucceededNotification = @"LQAnonymousSignupSucceededNotification";
static NSString *const LQAnonymousSignupFailedNotification = @"LQAnonymousSignupFailedNotification";
static NSString *const LQAPIUnknownErrorNotification = @"LQAPIUnknownErrorNotification";

// __dhan: strings to set the sending method
static NSString *const LQSendingMethodUDP = @"LQSendingMethodUDP";
static NSString *const LQSendingMethodHTTP = @"LQSendingMethodHTTP";
static NSString *const LQLocationUpdateManagerToggleTrackingDefaultKey = @"LQLocationUpdateManagerToggleTrackingDefaultKey";
static NSString *const LQLocationUpdateManagerUpdatesOnUserDefaultsKey = @"LQLocationUpdateManagerUpdatesOnUserDefaultskey";
static NSString *const LQLocationUpdateManagerCurrentTrackingModeKey = @"LocationUpdateManagerCurrentTrackingModeKey";
static NSString *const LQLocationUpdateManagerTrackingModeKey = @"LQLocationUpdateManagerTrackingModeKey";




enum {
	LQPresetBattery = 0,
	LQPresetRealtime
};

enum {
    LQBatterySaverMode = 0,
    LQHiResMode,
    LQCustomMode
    };

typedef void (^LQHTTPRequestCallback)(NSError *error, NSString *responseBody);


@interface Geoloqi : NSObject 
{
}

@property (nonatomic, assign) CLLocationDistance recallDistanceFilterDistance;
@property (nonatomic, assign) NSTimeInterval recallTrackingFrequency;
@property (nonatomic, assign) NSTimeInterval recallSendingFrequency;

+ (Geoloqi *) sharedInstance;

#pragma mark Application
- (void)setUserAgentString:(NSString *)ua;
- (void)sendAPNDeviceToken:(NSString *)deviceToken developmentMode:(NSString *)devMode callback:(LQHTTPRequestCallback)callback;
- (void)sendDeviceIdwithcallback:(LQHTTPRequestCallback)callback;
- (void)createGeonote:(NSString *)text latitude:(float)latitude longitude:(float)longitude radius:(float)radius callback:(LQHTTPRequestCallback)callback;
- (void)createLink:(NSString *)description minutes:(NSInteger)minutes callback:(LQHTTPRequestCallback)callback;
- (void)getBannerForLocation:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback;
- (void)addShutdownTimer:(id)notification;
- (void)cancelShutdownTimers;
- (void)appDidEnterBackground;
- (void)appDidEnterForeground;

#pragma mark Layers
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
- (void)setSendMethod;
- (void)setLocationUpdatesOnTo:(BOOL)value;           // __dbhan: default ON; ON = tracking, off = not tracking;;
- (void)setTrackingModeTo:(int)trackingMode;
- (int)trackingMode;
- (void)setTrackingPreset:(int)trackingMode;         //__dbhan: Get the tracking mode presets


- (NSDate *)lastLocationDate;
- (NSDate *)lastUpdateDate;
- (CLLocation *)currentSingleLocation;
- (CLLocation *)currentLocation;
- (BOOL)locationUpdatesState;
- (CLLocationDistance)distanceFilterDistance;
- (NSTimeInterval)trackingFrequency;
- (NSTimeInterval)sendingFrequency;
- (void)loadHistory:(NSDictionary *)params callback:(LQHTTPRequestCallback)callback;
- (void)sendLocationData:(NSMutableArray *)points callback:(LQHTTPRequestCallback)callback;
- (void)sendQueuedPoints;
- (NSDictionary *)dictionaryFromLocation:(CLLocation *)location;

//__dbhan: get/set locationQueueCount
- (void)setLocationQueueCountTo:(NSUInteger)value;
- (NSUInteger)getLocationQueueCount;

//__dbhan: getters tracking mode and related data required
- (int)getTrackingMode;
- (int)getRecallTrackingMode;
- (CLLocationDistance)getRecallDistanceFilterDistance;
- (NSTimeInterval)getRecallSendingFrequency;
- (NSTimeInterval)getRecallTrackingFrequency;

//__dbhan: setters tracking mode and related data required
- (void)setTrackingModeTo:(int)value;
- (void)setRecallTrackingModeTo:(int)value;
- (void)setRecallDistanceFilterDistanceTo:(CLLocationDistance)value;
- (void)setRecallSendingFrequencyTo:(NSTimeInterval)value;
- (void)setRecallTrackingFrequencyTo:(NSTimeInterval)value;


#pragma mark Authentication

- (void)authenticateWithEmail:(NSString *)emailAddress password:(NSString *)password;
- (void)createAccountWithEmailAddress:(NSString *)emailAddress name:(NSString *)name;
- (void)authenticateWithAuthCode:(NSString *)authCode;
- (void)createAnonymousAccount;
- (void)createAnonymousAccount:(NSString*)name;
- (void)setAnonymousAccountEmail:(NSString *)emailAddress name:(NSString *)name;
- (void)initTokenAndGetUsername;

#pragma mark Invitation
- (void)createInvitation:(LQHTTPRequestCallback)callback;
- (void)getInvitationAtHost:(NSString *)host token:(NSString *)invitationToken callback:(LQHTTPRequestCallback)callback;
- (void)claimInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;
- (void)confirmInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;
- (void)getAccessTokenForInvitation:(NSString*)invitationToken callback:(LQHTTPRequestCallback)callback;
- (void)getLastPositions:(NSArray *)tokens callback:(LQHTTPRequestCallback)callback;

#pragma mark Twitter/Facebook/etc
- (void)postToFacebook:(NSString *)text url:(NSString *)url callback:(LQHTTPRequestCallback)callback;
- (void)postToTwitter:(NSString *)text callback:(LQHTTPRequestCallback)callback;

#pragma mark -
- (void)trackPushNotificationView:(NSDictionary *)params callback:(LQHTTPRequestCallback)callback;
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
