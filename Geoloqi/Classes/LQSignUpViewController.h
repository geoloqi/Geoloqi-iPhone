//
//  LQSignUpViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CTableViewController.h"

@interface LQSignUpViewController : CTableViewController {

}

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *emailAddressField;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)cancel;
- (IBAction)signUpAction;

@end
