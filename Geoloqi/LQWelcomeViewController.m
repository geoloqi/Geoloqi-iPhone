//
//  LQWelcomeViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQWelcomeViewController.h"


@implementation LQWelcomeViewController

@synthesize signUpViewController, logInViewController;
@synthesize signUpButton;
@synthesize signInButton;
@synthesize useAnonymouslyButton;

- (IBAction)signUp {
	[self presentModalViewController:signUpViewController
							animated:YES];
}
- (IBAction)logIn {
	[self presentModalViewController:logInViewController
							animated:YES];
}
- (IBAction)useAnonymously {
	[[Geoloqi sharedInstance] createAnonymousAccount];
}

- (void)viewDidLoad;
{
	UIImage *stretImg = [[UIImage imageNamed:@"signin-btn.png"] stretchableImageWithLeftCapWidth:18.f topCapHeight:0.f];
	UIImage *stretImgSm = [[UIImage imageNamed:@"small-btn.png"] stretchableImageWithLeftCapWidth:16.f topCapHeight:0.f];
	[self.signUpButton setBackgroundImage:stretImg forState:UIControlStateNormal];
	[self.useAnonymouslyButton setBackgroundImage:stretImg forState:UIControlStateNormal];
	[self.signInButton setBackgroundImage:stretImgSm forState:UIControlStateNormal];
	
}

#pragma mark -
#pragma mark Lifecycle
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[signUpViewController release];
	[logInViewController release];
	[signUpButton release];
	[signInButton release];
	[useAnonymouslyButton release];
    [super dealloc];
}


@end
