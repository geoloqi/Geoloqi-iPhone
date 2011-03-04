//
//  LQWelcomeViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQWelcomeViewController.h"
#import "LQAboutViewController.h"
#import "SHKActivityIndicator.h"


@implementation LQWelcomeViewController

@synthesize signUpViewController, logInViewController, twitterAuthViewController;
@synthesize signUpButton, signInButton, useAnonymouslyButton, twitterAuthButton;
@synthesize activityIndicator;
@synthesize emailAddressField;
@synthesize errorMessageLabel;

- (IBAction)signUp {
	if([self.emailAddressField.text isEqualToString:@""])
		return;
	
	[GeoloqiAppDelegate userIsNotAnonymous];
	
	[self startLoading];

    [[Geoloqi sharedInstance] createAccountWithEmailAddress:self.emailAddressField.text
													   name:@""];
}
- (IBAction)logIn {
	[GeoloqiAppDelegate userIsNotAnonymous];
	[self presentModalViewController:logInViewController
							animated:YES];
}
- (IBAction)useAnonymously {
	[GeoloqiAppDelegate userIsAnonymous];
	[[Geoloqi sharedInstance] createAnonymousAccount];
	[self startLoading];
}

- (IBAction)twitterAuth {
	[GeoloqiAppDelegate userIsNotAnonymous];
	[self presentModalViewController:twitterAuthViewController
							animated:YES];
}

- (IBAction)about {
	LQAboutViewController *aboutView = [[LQAboutViewController alloc] init];
	[self presentModalViewController:aboutView animated:YES];
	[aboutView release];
}

- (void)startLoading {
	self.errorMessageLabel.text = @"";
	[UIView beginAnimations:nil context:NULL];
	self.activityIndicator.alpha = 1.0f;
	[UIView commitAnimations];
}

- (void)stopLoading {
	[UIView beginAnimations:nil context:NULL];
	self.activityIndicator.alpha = 0.0f;
	[UIView commitAnimations];
}

- (void)viewDidLoad;
{
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"welcomeBkg.png"]]];
	[self stopLoading];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return NO;
}

// Hide the keyboard when the background is tapped
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	for (UITouch *touch in touches){
		if (touch.view == self.view){
			[self.emailAddressField resignFirstResponder];
		}
	}
}

#pragma mark -
#pragma mark Lifecycle
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)authenticationDidFail:(NSNotification *)notification {
	NSLog(@"Error: %@", [notification.userInfo objectForKey:@"error_description"]);
	
	if([[notification.userInfo objectForKey:@"error"] isEqualToString:@"email_exists"]) {
		gAppDelegate.signInEmailAddress = self.emailAddressField.text;
		// Open up the login screen
		[self logIn];
	} else if([notification.userInfo objectForKey:@"error"] != nil) {
		if([notification.userInfo objectForKey:@"error_description"] != nil) {
			self.errorMessageLabel.text = [notification.userInfo objectForKey:@"error_description"];
		}
	} else {
//		[[SHKActivityIndicator topIndicator] displayCompleted:@"Registration Failed!"];
//		[[SHKActivityIndicator topIndicator] setCenterMessage:@"✕"];
	}
	[self stopLoading];
}

- (void)viewWillAppear:(BOOL)animated {
	[self stopLoading];
	self.errorMessageLabel.text = @"";
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(authenticationDidFail:) 
												 name:LQAuthenticationFailedNotification 
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self stopLoading];
	self.errorMessageLabel.text = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationFailedNotification 
                                                  object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[signUpViewController release];
	[logInViewController release];
	[twitterAuthViewController release];
	[signUpButton release];
	[signInButton release];
	[useAnonymouslyButton release];
	[twitterAuthButton release];
    [super dealloc];
}


@end
