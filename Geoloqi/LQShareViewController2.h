//
//  LQShareViewController2.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQShareService.h"

@interface LQShareViewController2 : UIViewController {
	NSString *shareButtonPressed;
	LQShareService *sharer;
	IBOutlet UIButton *shareBtnCopy, *shareBtnFacebook, *shareBtnSMS, *shareBtnEmail, *shareBtnTwitter;
	IBOutlet UIView *activityIndicator;
	IBOutlet UITextView *textView;
	IBOutlet UILabel *charCounter;
}

typedef enum {
	LQShareMethodEmail = 0,
	LQShareMethodSMS,
	LQShareMethodTwitter,
	LQShareMethodFacebook,
	LQShareMethodCopy
} LQShareMethod;

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) NSString *shareButtonPressed;
@property (nonatomic, retain) LQShareService *sharer;

- (IBAction)backWasTapped;
- (IBAction)doneWasTapped;

- (void)shareLink:(NSURL *)url 
	  withMessage:(NSString *)message
			  via:(LQShareMethod)method 
		  minutes:(NSNumber *)minutes 
		 canTweet:(BOOL)canTweet 
	  canFacebook:(BOOL)canFacebook;

@end
