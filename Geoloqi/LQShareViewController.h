//
//  LQShareViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQShareService.h"

@interface LQShareViewController : UIViewController
			<UIPickerViewDataSource, UIPickerViewDelegate> {
	NSMutableArray *durations;
	NSMutableArray *durationMinutes;
	NSString *selectedMinutes;
	IBOutlet UIView *activityIndicator;
	UITextView *shareDescriptionField;
	NSString *sharedLinkCreated;
	NSString *shareButtonPressed;
	LQHTTPRequestCallback linkCreatedCallback;
	IBOutlet UINavigationBar *navigationBar;
	LQShareService *sharer;

	IBOutlet UIButton *shareBtnEmail, *shareBtnSMS, *shareBtnTwitter, *shareBtnFacebook, *shareBtnCopy;
}

typedef enum {
	LQShareMethodEmail = 0,
	LQShareMethodSMS,
	LQShareMethodTwitter,
	LQShareMethodFacebook,
	LQShareMethodCopy
} LQShareMethod;


@property (nonatomic, retain) IBOutlet UITextView *shareDescriptionField;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *durations;
@property (nonatomic, retain) NSMutableArray *durationMinutes;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, retain) NSString *shareButtonPressed;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) LQShareService *sharer;

- (LQHTTPRequestCallback)linkCreatedCallback;
- (IBAction)tappedShare:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)cancelWasTapped;
- (void)shareLink:(NSURL *)url via:(LQShareMethod)method;
//- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes;

@end
