//
//  LQShareViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQShareViewController : UIViewController
			<UIPickerViewDataSource, UIPickerViewDelegate> {
	NSMutableArray *durations;
	NSMutableArray *durationMinutes;
	NSString *selectedMinutes;
	IBOutlet UIView *activityIndicator;
	UITextField *shareDescriptionField;
	NSString *sharedLinkCreated;
	LQHTTPRequestCallback linkCreatedCallback;

	IBOutlet UIButton *shareBtnEmail, *shareBtnSMS, *shareBtnTwitter, *shareBtnFacebook, *shareBtnCopy;
}

@property (nonatomic, retain) IBOutlet UITextField *shareDescriptionField;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *durations;
@property (nonatomic, retain) NSMutableArray *durationMinutes;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (LQHTTPRequestCallback)linkCreatedCallback;
- (IBAction)tappedShare:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)cancelWasTapped;
//- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes;

@end
