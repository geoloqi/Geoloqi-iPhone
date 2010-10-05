//
//  GLWelcomeViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import "GLWelcomeViewController.h"


@implementation GLWelcomeViewController

@synthesize signUpViewController, logInViewController;

- (IBAction)signUp {
	[self presentModalViewController:signUpViewController
							animated:YES];
}
- (IBAction)logIn {
	[self presentModalViewController:logInViewController
							animated:YES];
}
- (IBAction)useAnonymously {
	
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
    [super dealloc];
}


@end
