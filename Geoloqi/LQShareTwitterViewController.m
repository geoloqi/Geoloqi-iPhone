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
@synthesize activityIndicator;
@synthesize sendButton;
@synthesize textView;
@synthesize charCounter;
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
	cancelButton.action = @selector(cancelWasTapped);
	item.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	BlueButton *blueSendButton = [[BlueButton alloc] init];
	[blueSendButton setTitle:@"Send" forState:UIControlStateNormal];
	[blueSendButton addTarget:self action:@selector(sendWasTapped) forControlEvents:UIControlEventTouchUpInside];
	self.sendButton = [[UIBarButtonItem alloc] initWithCustomView:blueSendButton];
	item.rightBarButtonItem = sendButton;
	[blueSendButton release];

	item.hidesBackButton = YES;
	[navigationBar pushNavigationItem:item animated:NO];
	[item release];
	
	[navigationBar release];

	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture.png"]]];

	[self.textView becomeFirstResponder];
	[self.textView setText:self.message];
	[self updateCharacterCounter];
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

- (void)updateCharacterCounter {
	int remaining = 140 - [self.textView.text length];
	[self.charCounter setText:[NSString stringWithFormat:@"%d", remaining]];
	if(remaining < 0) {
		self.charCounter.textColor = [UIColor colorWithRed:170.0 green:0 blue:0 alpha:1.0];
		self.sendButton.enabled = NO;
	} else {
		self.charCounter.textColor = [UIColor whiteColor];
		self.sendButton.enabled = YES;
	}
}

/*
 * Press "Send" when the user presses the Send key on the keyboard. This also means it's impossible to type a newline into the box.
 * Count down from 140 characters.
 */
- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqual:@"\n"]) {
		[self sendWasTapped];
		return NO;
	}
	[self updateCharacterCounter];
	return YES;
}

- (void)sendWasTapped {
	// Prevent pressing "Send" on the keyboard from trying to post a tweet if the actual "Send" button is disabled
	if(self.sendButton.enabled == NO){
		return;
	}

	self.activityIndicator.alpha = 1.0f;
	
	// Try to post the tweet!
	[[Geoloqi sharedInstance] postToTwitter:self.textView.text
								   callback:self.tweetPostedCallback];
}

- (LQHTTPRequestCallback)tweetPostedCallback {
	if (tweetPostedCallback) return tweetPostedCallback;
	return tweetPostedCallback = [^(NSError *error, NSString *responseBody) {

		self.activityIndicator.alpha = 0.0f;

		
		[self.delegate twitterDidFinish];
	} copy];
}
		
- (void)cancelWasTapped {
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
	[activityIndicator release];
	[sendButton release];
	[textView release];
	[charCounter release];
	[message release];
    [super dealloc];
}


@end

