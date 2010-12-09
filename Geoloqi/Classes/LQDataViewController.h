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

@interface LQDataViewController : UITableViewController {
	UITableViewCell *coordsCell;
	UILabel *latLabel;
	UILabel *longLabel;
	
	UITableViewCell *trackingToggleCell;
	UISwitch *trackingToggleSwitch;
	
	UITableViewCell *trackingFrequencyCell;
	UILabel *trackingFrequencyLabel;
	LQMappedSlider *trackingFrequencySlider;
	
	UITableViewCell *distanceFilterCell;
	UILabel *distanceFilterLabel;
	LQMappedSlider *distanceFilterSlider;
	
	UITableViewCell *sendingFrequencyCell;
	UILabel *sendingFrequencyLabel;
	LQMappedSlider *sendingFrequencySlider;

	NSTimer *viewRefreshTimer;
}
@property (nonatomic, retain) IBOutlet UITableViewCell *coordsCell;
@property (nonatomic, retain) IBOutlet UILabel *latLabel;
@property (nonatomic, retain) IBOutlet UILabel *longLabel;

@property (nonatomic, retain) IBOutlet UITableViewCell *trackingToggleCell;
@property (nonatomic, retain) IBOutlet UISwitch *trackingToggleSwitch;
- (void)toggleTracking:(UISwitch *)sender;

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
- (void)changeSendingFrequency:(LQMappedSlider *)sender;
- (void)sendingFrequencyWasChanged:(LQMappedSlider *)sender;

- (void)viewRefreshTimerDidFire:(NSTimer *)timer;

@end
