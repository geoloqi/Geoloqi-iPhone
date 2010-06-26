//
//  GLDataViewController.h
//  LocationUpdater
//
//  Created by caseorganic on 6/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const GLTrackingOnUserInfoKey;

@interface GLDataViewController : UITableViewController {
	UITableViewCell *coordsCell;
	UILabel *latLabel;
	UILabel *longLabel;
	
	UITableViewCell *trackingToggleCell;
	UISwitch *trackingToggleSwitch;
	
	UITableViewCell *trackingFrequencyCell;
	UILabel *trackingFrequencyLabel;
	UISlider *trackingFrequencySlider;
	
	UITableViewCell *distanceFilterCell;
	UISlider *distanceFilterSlider;
	UILabel *distanceFilterLabel;
	
	UITableViewCell *sendingFrequencyCell;
	UILabel *sendingFrequencyLabel;
	UISlider *sendingFrequencySlider;
}
@property (nonatomic, retain) IBOutlet UITableViewCell *coordsCell;
@property (nonatomic, retain) IBOutlet UILabel *latLabel;
@property (nonatomic, retain) IBOutlet UILabel *longLabel;

@property (nonatomic, retain) IBOutlet UITableViewCell *trackingToggleCell;
@property (nonatomic, retain) IBOutlet UISwitch *trackingToggleSwitch;
- (void)toggleTracking:(UISwitch *)sender;

@property (nonatomic, retain) IBOutlet UITableViewCell *distanceFilterCell;
@property (nonatomic, retain) IBOutlet UILabel *distanceFilterLabel;
@property (nonatomic, retain) IBOutlet UISlider *distanceFilterSlider;
- (void)changeDistanceFilter:(UISlider *)sender;

@property (nonatomic, retain) IBOutlet UITableViewCell *trackingFrequencyCell;
@property (nonatomic, retain) IBOutlet UILabel *trackingFrequencyLabel;
@property (nonatomic, retain) IBOutlet UISlider *trackingFrequencySlider;
- (void)changeTrackingFrequency:(UISlider *)sender;

@property (nonatomic, retain) IBOutlet UITableViewCell *sendingFrequencyCell;
@property (nonatomic, retain) IBOutlet UILabel *sendingFrequencyLabel;
@property (nonatomic, retain) IBOutlet UISlider *sendingFrequencySlider;
- (void)changeSendingFrequency:(UISlider *)sender;


@end
