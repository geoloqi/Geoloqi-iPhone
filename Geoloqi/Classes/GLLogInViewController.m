//
//  GLLogInViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import "GLLogInViewController.h"
#import "GLAuthenticationManager.h"

@implementation GLLogInViewController

@synthesize usernameField, passwordField;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}
- (IBAction)done {
	[[GLAuthenticationManager sharedManager] authenticateWithUsername:usernameField.text
															 password:passwordField.text];
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
	[usernameField release];
	[passwordField release];
    [super dealloc];
}


@end
