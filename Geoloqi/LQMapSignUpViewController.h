//
//  LQMapSignUpViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/2/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CTableViewController.h"

@interface LQMapSignUpViewController : CTableViewController {
	
}

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *emailAddressField;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)cancel;
- (IBAction)signUpAction;
- (IBAction)textFieldReturn:(id)sender;

@end
