//
//  LQWelcomeViewController.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LQWelcomeViewController : UIViewController <UITextFieldDelegate> {

}
@property (nonatomic, retain) IBOutlet UIViewController *signUpViewController;
@property (nonatomic, retain) IBOutlet UIViewController *logInViewController;
@property (nonatomic, retain) IBOutlet UIViewController *twitterAuthViewController;

@property (nonatomic, retain) IBOutlet UIButton *signUpButton;
@property (nonatomic, retain) IBOutlet UIButton *signInButton;
@property (nonatomic, retain) IBOutlet UIButton *useAnonymouslyButton;
@property (nonatomic, retain) IBOutlet UIButton *twitterAuthButton;

@property (nonatomic, retain) IBOutlet UITextField *emailAddressField;
@property (nonatomic, retain) IBOutlet UILabel *errorMessageLabel;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)signUp;
- (IBAction)useAnonymously;
- (IBAction)logIn;
- (IBAction)twitterAuth;
- (IBAction)about;
- (void)startLoading;
- (void)stopLoading;

@end
