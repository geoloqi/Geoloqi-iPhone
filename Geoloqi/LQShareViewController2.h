//
//  LQShareViewController2.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQShareService.h"
#import "Geoloqi.h"
#import "LQShareTwitterConnectViewController.h"
#import "LQShareFacebookConnectViewController.h"

@interface LQShareViewController2 : UIViewController <LQShareTwitterConnectDelegate, LQShareFacebookConnectDelegate> {
	NSString *shareButtonPressed;
	LQShareService *sharer;
	IBOutlet UIButton *shareBtnCopy, *shareBtnFacebook, *shareBtnSMS, *shareBtnEmail, *shareBtnTwitter;
	IBOutlet UIView *activityIndicator;
	IBOutlet UITextView *textView;
	IBOutlet UILabel *charCounter;
	BOOL canFacebook;
	BOOL canTwitter;
	LQHTTPRequestCallback tweetPostedCallback;
	LQHTTPRequestCallback facebookPostedCallback;
}

typedef enum {
	LQShareMethodUnknown = -1,
	LQShareMethodEmail,
	LQShareMethodSMS,
	LQShareMethodTwitter,
	LQShareMethodFacebook,
	LQShareMethodCopy
} LQShareMethod;

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) NSString *shareButtonPressed;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, retain) LQShareService *sharer;
@property (nonatomic, retain) NSURL *shareURL;
@property (nonatomic, retain) NSString *shareMessage;
@property (nonatomic, retain) NSNumber *shareMinutes;

- (id)initWithURL:(NSURL *)url 
	   andMessage:(NSString *)message 
	  forDuration:(NSNumber *)minutes 
	   canTwitter:(BOOL)twitter
	  canFacebook:(BOOL)facebook;

- (LQHTTPRequestCallback)tweetPostedCallback;
- (LQHTTPRequestCallback)facebookPostedCallback;

- (IBAction)backWasTapped;
- (IBAction)doneWasTapped;
- (IBAction)shareServiceButtonWasTapped:(id)sender;

- (void)shareLinkVia:(LQShareMethod)method;

@end
