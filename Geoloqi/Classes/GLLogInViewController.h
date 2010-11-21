//
//  GLLogInViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CTableViewController.h"

@interface GLLogInViewController : CTableViewController {

}
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)cancel;
- (IBAction)logInAction;

@end
