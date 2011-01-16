//
//  LQShareTwitterViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQShareTwitterViewController : UIViewController <UITextViewDelegate> {
	id delegate;
	UINavigationBar *navigationBar;
	IBOutlet UITextView *textView;
	IBOutlet UILabel *charCounter;
	UIBarButtonItem *sendButton;
	NSString *message;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *charCounter;
@property (nonatomic, retain) NSString *message;

- (LQShareTwitterViewController *)initWithMessage:(NSString *)_message;
- (void)updateCharacterCounter;
- (void)sendWasTapped;
- (void)cancelWasTapped;

@end


@protocol LQShareTwitterDelegate
- (void)twitterDidCancel;
- (void)twitterDidFinish;
@end