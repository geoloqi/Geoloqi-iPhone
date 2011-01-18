//
//  LQShareFacebookViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"


@interface LQShareFacebookViewController : UIViewController <UITextViewDelegate> {
	id delegate;
	UINavigationBar *navigationBar;
	IBOutlet UIView *activityIndicator;
	IBOutlet UITextView *textView;
	IBOutlet UILabel *charCounter;
	UIBarButtonItem *sendButton;
	NSString *message;
	NSString *url;
	LQHTTPRequestCallback tweetPostedCallback;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *charCounter;
@property (nonatomic, retain) NSString *message, *url;

- (LQShareFacebookViewController *)initWithMessage:(NSString *)_message andURL:(NSString *)_url;
- (void)updateCharacterCounter;
- (void)sendWasTapped;
- (LQHTTPRequestCallback)tweetPostedCallback;
- (void)cancelWasTapped;

@end


@protocol LQShareFacebookDelegate
- (void)facebookDidCancel;
- (void)facebookDidFinish;
@end