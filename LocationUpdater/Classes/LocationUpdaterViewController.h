//
//  LocationUpdaterViewController.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright Darknoon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface LocationUpdaterViewController : UIViewController {
	IBOutlet UIButton *significantUpdateToggle;
	IBOutlet UIButton *locationUpdateToggle;
	IBOutlet UITextField *deviceKeyField;
	
	IBOutlet UILabel *distanceFilterLabel;
	IBOutlet UISlider *distanceFilterSlider;
}

@property (nonatomic, retain) UITextField *deviceKeyField;
@property (nonatomic, retain) UISlider *distanceFilterSlider;
@property (nonatomic, retain) UIButton *significantUpdateToggle;
@property (nonatomic, retain) UIButton *locationUpdateToggle;

- (IBAction)toggleSignificantUpdate;
- (IBAction)toggleLocationUpdate;

- (IBAction)distanceFilterChanged:(UISlider *)sender;

@end

