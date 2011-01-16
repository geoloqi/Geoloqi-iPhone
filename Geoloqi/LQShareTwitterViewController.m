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
@synthesize navigationBar;
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
	
	navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self.view addSubview:navigationBar];

	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"New Tweet"];

	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] init];
	[cancelButton setTitle:@"Cancel"];
	cancelButton.target = self;
	cancelButton.action = @selector(cancelWasTapped:);
	item.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	BlueButton *blueSendButton = [[BlueButton alloc] init];
	[blueSendButton setTitle:@"Send" forState:UIControlStateNormal];
	[blueSendButton addTarget:self action:@selector(sendWasTapped:) forControlEvents:UIControlEventTouchUpInside];
	item.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:blueSendButton] autorelease];
	[blueSendButton release];

	item.hidesBackButton = YES;
	[navigationBar pushNavigationItem:item animated:NO];
	[item release];
	
	[navigationBar release];

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

- (void)cancelWasTapped:(id)sender {
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
	navigationBar = nil;
}


- (void)dealloc {
	[delegate release];
	[navigationBar release];
	[textView release];
	[message release];
    [super dealloc];
}


@end

