//
//  LQShareTwitterViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"


@interface LQShareTwitterViewController : UIViewController <UITextViewDelegate> {
	id delegate;
	UINavigationBar *navigationBar;
	IBOutlet UIView *activityIndicator;
	IBOutlet UITextView *textView;
	IBOutlet UILabel *charCounter;
	UIBarButtonItem *sendButton;
	NSString *message;
	LQHTTPRequestCallback tweetPostedCallback;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *charCounter;
@property (nonatomic, retain) NSString *message;

- (LQShareTwitterViewController *)initWithMessage:(NSString *)_message;
- (void)updateCharacterCounter;
- (void)sendWasTapped;
- (LQHTTPRequestCallback)tweetPostedCallback;
- (void)cancelWasTapped;

@end


@protocol LQShareTwitterDelegate
- (void)twitterDidCancel;
- (void)twitterDidFinish;
@end