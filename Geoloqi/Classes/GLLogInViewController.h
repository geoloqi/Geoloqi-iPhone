//
//  GLLogInViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLLogInViewController : UIViewController {

}
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

- (IBAction)cancel;
- (IBAction)done;

@end
