//
//  GLWelcomeViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLWelcomeViewController : UIViewController {
	
}
@property (nonatomic, retain) IBOutlet UIViewController *signUpViewController;
@property (nonatomic, retain) IBOutlet UIViewController *logInViewController;

- (IBAction)signUp;
- (IBAction)useAnonymously;
- (IBAction)logIn;

@end
