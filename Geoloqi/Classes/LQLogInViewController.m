//
//  LQLogInViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQLogInViewController.h"

@implementation LQLogInViewController

@synthesize usernameField, passwordField, activityIndicator;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}
- (IBAction)logInAction {
	[[Geoloqi sharedInstance] authenticateWithUsername:usernameField.text
															 password:passwordField.text];

	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;

	[UIView beginAnimations:nil context:NULL];
	self.activityIndicator.alpha = 1.0f;
	[UIView commitAnimations];
}

- (NSString *)tableView:(UITableView *)inTableView titleForHeaderInSection:(NSInteger)section;
{
	return NSLocalizedString(@"Log in with your username and password", nil);
}

- (NSString *)tableView:(UITableView *)inTableView titleForFooterInSection:(NSInteger)section;
{
	return NSLocalizedString(@"", nil);
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	return 2;
}

- (BOOL)isComplete;
{
	return usernameField.text.length > 0 &&  passwordField.text.length > 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	
	if (indexPath.row == 0) {
		cell.accessoryView = usernameField;
		cell.detailTextLabel.text = NSLocalizedString(@"Username", nil);
	} else if  (indexPath.row == 1) {
		cell.accessoryView = passwordField;
		cell.detailTextLabel.text = NSLocalizedString(@"Password", nil);
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	[usernameField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
	self.navigationItem.rightBarButtonItem.enabled = [self isComplete];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)inTextField;
{
	if (inTextField == usernameField) {
		[passwordField becomeFirstResponder];
	} else if (inTextField == passwordField && [self isComplete]) {
		[self logInAction];
	}
	return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self 
																						   action:@selector(cancel)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Log In", nil)
																			   style:UIBarButtonItemStyleDone 
																			  target:self 
																			  action:@selector(logInAction)] autorelease];
	
	self.navigationItem.rightBarButtonItem.enabled = [self isComplete];
	
	self.title = NSLocalizedString(@"Log In", nil);
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
