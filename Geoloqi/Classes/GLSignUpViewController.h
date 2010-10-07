//
//  GLSignUpViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CTableViewController.h"

@interface GLSignUpViewController : CTableViewController {

}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *emailAddressField;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)cancel;
- (IBAction)signUpAction;

@end
