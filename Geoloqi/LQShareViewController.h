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
	UITextView *shareDescriptionField;
	NSString *sharedLinkCreated;
	NSNumber *shareMinutes;
	LQHTTPRequestCallback linkCreatedCallback;
	IBOutlet UIButton *shareBtn;
}

@property (nonatomic, retain) IBOutlet UITextView *shareDescriptionField;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *durations;
@property (nonatomic, retain) NSMutableArray *durationMinutes;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, retain) NSNumber *shareMinutes;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;

- (IBAction)tappedShare:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)cancelWasTapped;
- (LQHTTPRequestCallback)linkCreatedCallback;

@end
