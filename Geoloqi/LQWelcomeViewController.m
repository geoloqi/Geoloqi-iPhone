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


@implementation LQWelcomeViewController

@synthesize signUpViewController, logInViewController, twitterAuthViewController;
@synthesize signUpButton, signInButton, useAnonymouslyButton, twitterAuthButton;
@synthesize anonymousSpinner;
@synthesize emailAddressField;

- (IBAction)signUp {
	[GeoloqiAppDelegate userIsNotAnonymous];
	[self presentModalViewController:signUpViewController
							animated:YES];
}
- (IBAction)logIn {
	[GeoloqiAppDelegate userIsNotAnonymous];
	[self presentModalViewController:logInViewController
							animated:YES];
}
- (IBAction)useAnonymously {
	[GeoloqiAppDelegate userIsAnonymous];
	[[Geoloqi sharedInstance] createAnonymousAccount];
	self.anonymousSpinner.hidden = NO;
	self.useAnonymouslyButton.enabled = NO;
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

- (void)viewDidLoad;
{
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"welcomeBkg.png"]]];
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

- (void)viewWillAppear:(BOOL)animated {
	self.anonymousSpinner.hidden = YES;
	self.useAnonymouslyButton.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	self.anonymousSpinner.hidden = YES;
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
