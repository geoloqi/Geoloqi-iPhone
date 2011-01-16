//
//  LQShareTwitterViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareTwitterViewController.h"
#import "BlueButton.h"



@implementation LQShareTwitterViewController

@synthesize delegate;
@synthesize navigationItem;
@synthesize textView;
@synthesize message;

- (LQShareTwitterViewController *)initWithMessage:(NSString *)_message {
    if (self = [super init]) {
		self.message = _message;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	BlueButton *blueSendButton = [[BlueButton alloc] init];
	[blueSendButton setTitle:@"Send" forState:UIControlStateNormal];
	[blueSendButton addTarget:self action:@selector(sendWasTapped:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:blueSendButton] autorelease];
	[blueSendButton release];
	
	[self.textView becomeFirstResponder];
	[self.textView setText:self.message];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)sendWasTapped:(id)sender {
	
	[self.delegate twitterDidFinish];
}

- (IBAction)cancelWasTapped {
	[self.delegate twitterDidCancel];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

