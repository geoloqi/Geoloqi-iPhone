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
	IBOutlet UINavigationItem *navigationItem;
	IBOutlet UITextView *textView;
	NSString *message;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSString *message;

- (LQShareTwitterViewController *)initWithMessage:(NSString *)_message;
- (void)sendWasTapped:(id)sender;
- (IBAction)cancelWasTapped;

@end


@protocol LQShareTwitterDelegate
- (void)twitterDidCancel;
- (void)twitterDidFinish;
@end