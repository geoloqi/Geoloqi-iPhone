//
//  LQSignUpViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "LQSignUpViewController.h"
#import "SHKActivityIndicator.h"

@implementation LQSignUpViewController

@synthesize nameField;
@synthesize emailAddressField;
@synthesize activityIndicator;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)signUpAction {
    [[Geoloqi sharedInstance] createAccountWithEmailAddress:emailAddressField.text
													   name:nameField.text];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = YES;
	
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
	return NSLocalizedString(@"You'll get an email to complete the setup. You can start using Geoloqi right away!", nil);
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

- (void)authenticationDidFail:(NSNotificationCenter *)notification {
	[[SHKActivityIndicator topIndicator] displayCompleted:@"Signup Failed!"];
	[[SHKActivityIndicator topIndicator] setCenterMessage:@"✕"];
	self.activityIndicator.alpha = 0.0f;
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	[nameField becomeFirstResponder];

	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(authenticationDidFail:) 
												 name:LQAuthenticationFailedNotification 
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	// Closing the login view controller, reset to the default state
	self.navigationItem.rightBarButtonItem.enabled = YES;
	//self.navigationItem.leftBarButtonItem.enabled = NO;
	self.activityIndicator.alpha = 0.0f;

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationFailedNotification 
                                                  object:nil];
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
