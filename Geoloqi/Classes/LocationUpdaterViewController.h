//
//  LocationUpdaterViewController.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface LocationUpdaterViewController : UIViewController {
	IBOutlet UITextField *deviceKeyField;
	IBOutlet UITextField *serverURLField;
	IBOutlet UIButton *significantUpdateToggle;
	IBOutlet UIButton *locationUpdateToggle;
}

@property (nonatomic, retain) IBOutlet UITextField *deviceKeyField;
@property (nonatomic, retain) IBOutlet UITextField *serverURLField;
@property (nonatomic, retain) IBOutlet UIButton *significantUpdateToggle;
@property (nonatomic, retain) IBOutlet UIButton *locationUpdateToggle;

- (IBAction)toggleSignificantUpdate;

@end

