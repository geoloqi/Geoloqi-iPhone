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
	IBOutlet UITextField *deviceKeyField;
	IBOutlet UISlider *distanceFilterSlider;
	IBOutlet UIButton *significantUpdateToggle;
	IBOutlet UIButton *locationUpdateToggle;	
	IBOutlet UILabel *distanceFilterLabel;
}

@property (nonatomic, retain) IBOutlet UITextField *deviceKeyField;
@property (nonatomic, retain) IBOutlet UISlider *distanceFilterSlider;
@property (nonatomic, retain) IBOutlet UIButton *significantUpdateToggle;
@property (nonatomic, retain) IBOutlet UIButton *locationUpdateToggle;
@property (nonatomic, retain) IBOutlet UILabel *distanceFilterLabel;

- (IBAction)toggleSignificantUpdate;
- (IBAction)toggleLocationUpdate;
- (IBAction)distanceFilterChanged:(UISlider *)sender;

@end

