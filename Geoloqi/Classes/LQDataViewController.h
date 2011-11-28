//
//  LQDataViewController.h
//  Geoloqi
//
//  Created by caseorganic on 6/3/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"

NSString *const LQTrackingOnUserInfoKey;

@class LQMappedSlider;

@interface LQDataViewController : UIViewController {
	UITableView *table;
	
	UITableViewCell *updateQueueCell;
	IBOutlet UILabel *lastUpdateLabel;
	IBOutlet UILabel *inQueueLabel;
    UITableViewCell *realTimeTrackingCell;  // __dbhan: Table Cell realTimeTracking turns on/off (on = UDP; off = HTTP) We need this???
    UILabel *realTimeTrackingLabel;         // __dbhan: Label inside the realTimeTracking Table cell. This can be read. We need this???
    UISwitch* realTimeTrackingSwitch;       // __dbhan: The realTimeTrackingCell toggles states based on this switch

	
	UITableViewCell *coordsCell;
	UILabel *latLabel;
	UILabel *longLabel;
	UILabel *altLabel;
	UILabel *spdLabel;
	
	UITableViewCell *trackingToggleCell;
	UISwitch *trackingToggleSwitch;

	UITableViewCell *trackingModeCell;
	IBOutlet UISegmentedControl *trackingModeSwitch;

	UITableViewCell *checkInCell;
	IBOutlet UIButton *checkInButton;

	UITableViewCell *trackingFrequencyCell;
	UILabel *trackingFrequencyLabel;
	LQMappedSlider *trackingFrequencySlider;
	
	UITableViewCell *distanceFilterCell;
	UILabel *distanceFilterLabel;
	LQMappedSlider *distanceFilterSlider;
	
	UITableViewCell *sendingFrequencyCell;
	UILabel *sendingFrequencyLabel;
	LQMappedSlider *sendingFrequencySlider;

	IBOutlet UIButton *sendNowButton;
	IBOutlet UIActivityIndicatorView *sendingActivityIndicator;
	
	IBOutlet UIButton *trackingButton;
	
	UITableViewCell *logoutCell;
	IBOutlet UIButton *logoutButton;
	
	IBOutlet UIButton *aboutButton;
	
	NSTimer *viewRefreshTimer;
}
@property (nonatomic, retain) IBOutlet UITableView *table;

@property (nonatomic, retain) IBOutlet UITableViewCell *updateQueueCell;
- (IBAction)sendNowWasTapped:(UIButton *)button;

@property (nonatomic, retain) IBOutlet UITableViewCell *coordsCell;
@property (nonatomic, retain) IBOutlet UILabel *latLabel;
@property (nonatomic, retain) IBOutlet UILabel *longLabel;
@property (nonatomic, retain) IBOutlet UILabel *altLabel;
@property (nonatomic, retain) IBOutlet UILabel *spdLabel;

@property (nonatomic, retain) IBOutlet UITableViewCell *checkInCell;
@property (nonatomic, retain) IBOutlet UIButton *checkInButton;

@property (nonatomic, retain) IBOutlet UITableViewCell *trackingModeCell;
@property (nonatomic, retain) IBOutlet UISegmentedControl *trackingModeSwitch;
- (IBAction)trackingModeWasChanged:(UISegmentedControl *)control;

@property (nonatomic, retain) IBOutlet UITableViewCell *trackingToggleCell;
@property (nonatomic, retain) IBOutlet UISwitch *trackingToggleSwitch;
- (void)toggleTracking:(UISwitch *)sender;

@property (nonatomic, retain) IBOutlet UITableViewCell *realTimeTrackingCell; // __dbhan: expose the table cell as a property
@property (nonatomic, retain) IBOutlet UISwitch* realTimeTrackingSwitch;      //__dbhan: expose this switch as a property
@property (nonatomic, readonly) UILabel *realTimeTrackingLabel;              //__dbhan: Mark this as a readonly field as this deos not change
-(IBAction) toggleRealTimeTracking:(UISwitch *)sender;                            // __dbhan: 

@property (nonatomic, retain) IBOutlet UITableViewCell *distanceFilterCell;
@property (nonatomic, retain) IBOutlet UILabel *distanceFilterLabel;
@property (nonatomic, retain) IBOutlet LQMappedSlider *distanceFilterSlider;
- (void)changeDistanceFilter:(LQMappedSlider *)sender;

@property (nonatomic, retain) IBOutlet UITableViewCell *trackingFrequencyCell;
@property (nonatomic, retain) IBOutlet UILabel *trackingFrequencyLabel;
@property (nonatomic, retain) IBOutlet LQMappedSlider *trackingFrequencySlider;
- (void)changeTrackingFrequency:(LQMappedSlider *)sender;

@property (nonatomic, retain) IBOutlet UITableViewCell *sendingFrequencyCell;
@property (nonatomic, retain) IBOutlet UILabel *sendingFrequencyLabel;
@property (nonatomic, retain) IBOutlet LQMappedSlider *sendingFrequencySlider;

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UITableViewCell *logoutCell;
@property (nonatomic, retain) IBOutlet UIButton *logoutButton;

@property (nonatomic, retain) IBOutlet UIButton *aboutButton;

- (void)changeSendingFrequency:(LQMappedSlider *)sender;
- (void)sendingFrequencyWasChanged:(LQMappedSlider *)sender;

- (void)viewRefreshTimerDidFire:(NSTimer *)timer;

- (IBAction)checkInButtonWasTapped:(UIButton *)button;

- (void)updateButtonStates;

- (void)startedSendingLocations:(NSNotification *)notification;
- (void)finishedSendingLocations:(NSNotification *)notification;

- (IBAction)logoutButtonWasTapped:(UIButton *)button;

- (IBAction)aboutButtonWasTapped:(UIButton *)button;

@end
