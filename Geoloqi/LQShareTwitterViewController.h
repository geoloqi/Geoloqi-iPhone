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
	NSString *message;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSString *message;

- (LQShareTwitterViewController *)initWithMessage:(NSString *)_message;
- (void)sendWasTapped:(id)sender;
- (void)cancelWasTapped:(id)sender;

@end


@protocol LQShareTwitterDelegate
- (void)twitterDidCancel;
- (void)twitterDidFinish;
@end