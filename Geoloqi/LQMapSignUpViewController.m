//
//  LQMapSignUpViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/2/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQMapSignUpViewController.h"
#import "SHKActivityIndicator.h"

@implementation LQMapSignUpViewController

@synthesize nameField;
@synthesize emailAddressField;
@synthesize activityIndicator;

- (IBAction)cancel {
	[view_parentViewController(self) dismissModalViewControllerAnimated:YES];
}

- (IBAction)signUpAction {
    [[Geoloqi sharedInstance] setAnonymousAccountEmail:emailAddressField.text
												  name:nameField.text];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
	[self resignFirstResponder];
	
	[UIView beginAnimations:nil context:NULL];
	self.activityIndicator.alpha = 1.0f;
	[UIView commitAnimations];
}

- (NSString *)tableView:(UITableView *)inTableView titleForHeaderInSection:(NSInteger)section;
{
	return NSLocalizedString(@"Create your Geoloqi account", nil);
}

- (NSString *)tableView:(UITableView *)inTableView titleForFooterInSection:(NSInteger)section;
{
	return NSLocalizedString(@"You'll get an email to complete the setup.", nil);
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	return 2;
}

- (BOOL)isComplete;
{
	return nameField.text.length > 0 &&  emailAddressField.text.length > 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
	
	if (indexPath.row == 0) {
		cell.accessoryView = nameField;
		cell.detailTextLabel.text = NSLocalizedString(@"Your Name", nil);
	} else if  (indexPath.row == 1) {
		cell.accessoryView = emailAddressField;
		cell.detailTextLabel.text = NSLocalizedString(@"Email", nil);
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self 
																						   action:@selector(cancel)] autorelease];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Sign Up", nil)
																			   style:UIBarButtonItemStyleDone 
																			  target:self 
																			  action:@selector(signUpAction)] autorelease];

	self.navigationItem.rightBarButtonItem.enabled = [self isComplete];


	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(anonymousSignupDidSucceed:)
												 name:LQAnonymousSignupSucceededNotification 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(anonymousSignupDidFail:)
												 name:LQAnonymousSignupFailedNotification
											   object:nil];

	self.title = NSLocalizedString(@"Sign Up", nil);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
	self.navigationItem.rightBarButtonItem.enabled = [self isComplete];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)inTextField;
{
	if (inTextField == nameField) {
		[emailAddressField becomeFirstResponder];
	} else if (inTextField == emailAddressField && [self isComplete]) {
		[self signUpAction];
	}
	return YES;
}

- (IBAction)textFieldReturn:(id)sender
{
	// [sender resignFirstResponder];
}

- (void)anonymousSignupDidSucceed:(NSNotificationCenter *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:LQAuthenticationSucceededNotification 
												  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationFailedNotification 
                                                  object:nil];
	
	[GeoloqiAppDelegate userIsNotAnonymous];

	[self dismissModalViewControllerAnimated:YES];

	[[SHKActivityIndicator currentIndicator] displayCompleted:@"Thanks!"];
}

- (void)anonymousSignupDidFail:(NSNotificationCenter *)notification
{
	[[SHKActivityIndicator topIndicator] displayCompleted:@"Error"];
	[[SHKActivityIndicator topIndicator] setCenterMessage:@"✕"];

	[self.nameField becomeFirstResponder];
	self.activityIndicator.hidden = YES;
}
	 

- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	[nameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	// Closing the login view controller, reset to the default state
	self.navigationItem.rightBarButtonItem.enabled = YES;
	//self.navigationItem.leftBarButtonItem.enabled = NO;
	self.activityIndicator.alpha = 0.0f;
}

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
    [nameField release];
    [emailAddressField release];
    [super dealloc];
}



@end

