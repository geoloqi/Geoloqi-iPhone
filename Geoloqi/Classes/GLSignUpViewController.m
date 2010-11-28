//
//  GLSignUpViewController.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "GLSignUpViewController.h"

@implementation GLSignUpViewController

@synthesize usernameField;
@synthesize emailAddressField;
@synthesize activityIndicator;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)signUpAction {
    [[Geoloqi sharedInstance] createAccountWithUsername:usernameField.text 
                                                          emailAddress:emailAddressField.text];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;
	
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
	return NSLocalizedString(@"You'll get an email to complete the setup, but you can start using the app right away!", nil);
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
{
	return 2;
}

- (BOOL)isComplete;
{
	return usernameField.text.length > 0 &&  emailAddressField.text.length > 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];

	if (indexPath.row == 0) {
		cell.accessoryView = emailAddressField;
		cell.detailTextLabel.text = NSLocalizedString(@"Email", nil);
	} else if  (indexPath.row == 1) {
		cell.accessoryView = usernameField;
		cell.detailTextLabel.text = NSLocalizedString(@"Username", nil);
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
	if (inTextField == emailAddressField) {
		[usernameField becomeFirstResponder];
	} else if (inTextField == usernameField && [self isComplete]) {
		[self signUpAction];
	}
	return YES;
}

- (void)viewWillAppear:(BOOL)animated;
{
	[super viewWillAppear:animated];
	[emailAddressField becomeFirstResponder];
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
    [usernameField release];
    [emailAddressField release];
    [super dealloc];
}


@end
