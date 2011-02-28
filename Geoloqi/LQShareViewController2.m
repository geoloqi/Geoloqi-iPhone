//
//  LQShareViewController2.m
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareViewController2.h"
#import "LQShareMail.h"
#import "LQShareSMS.h"
#import "LQShareTwitter.h"
#import "LQShareFacebook.h"


@implementation LQShareViewController2

@synthesize navigationItem;
@synthesize shareButtonPressed;
@synthesize sharer;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture.png"]]];
	
	[gAppDelegate makeLQButton:shareBtnEmail];
	[gAppDelegate makeLQButton:shareBtnSMS];
	[gAppDelegate makeLQButton:shareBtnTwitter];
	[gAppDelegate makeLQButton:shareBtnFacebook];
	[gAppDelegate makeLQButton:shareBtnCopy];
}

- (LQShareMethod)stringToShareMethod:(NSString *)str {
	LQShareMethod method;
	if([str isEqualToString:@"Email"]){
		method = LQShareMethodEmail;
	} else if([str isEqualToString:@"SMS"]){
		method = LQShareMethodSMS;
	} else if([str isEqualToString:@"Twitter"]){
		method = LQShareMethodTwitter;
	} else if([str isEqualToString:@"Facebook"]){
		method = LQShareMethodFacebook;
	} else if([str isEqualToString:@"Copy Link"]){
		method = LQShareMethodCopy;
	}
	return method;
}

- (IBAction)backWasTapped {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneWasTapped {
	[self.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];
}

/*
[self shareLink:url 
			via:LQShareMethodCopy
		minutes:self.shareMinutes
	   canTweet:[[res objectForKey:@"can_tweet"] isEqualToNumber:[NSNumber numberWithInt:1]]
	canFacebook:[[res objectForKey:@"can_facebook"] isEqualToNumber:[NSNumber numberWithInt:1]]];
*/

- (void)shareLink:(NSURL *)url 
	  withMessage:(NSString *)message
			  via:(LQShareMethod)method 
		  minutes:(NSNumber *)minutes
		 canTweet:(BOOL)canTweet
	  canFacebook:(BOOL)canFacebook {
	
	if([message length] == 0){
		message = @"Heading out! Track me on Geoloqi!";
	}
	
	switch(method){
		case LQShareMethodEmail:
			sharer = [[LQShareMail alloc] initWithController:self];
			[sharer shareURL:url withMessage:message minutes:minutes];
			break;
		case LQShareMethodSMS:
			sharer = [[LQShareSMS alloc] initWithController:self];
			[sharer shareURL:url withMessage:message minutes:minutes];
			break;
		case LQShareMethodTwitter:
			sharer = [[LQShareTwitter alloc] initWithController:self];
			[sharer shareURL:url withMessage:message minutes:minutes canPost:canTweet];
			break;
		case LQShareMethodFacebook:
			sharer = [[LQShareFacebook alloc] initWithController:self];
			[sharer shareURL:url withMessage:message minutes:minutes canPost:canFacebook];
			break;
		case LQShareMethodCopy:
			[[UIPasteboard generalPasteboard] setString:url.absoluteString];
			// [[SHKActivityIndicator currentIndicator] displayCompleted:SHKLocalizedString(@"Copied!")];
			[LQShareService linkWasSent:@"Link Copied" minutes:minutes];
			[self.parentViewController dismissModalViewControllerAnimated:YES];
			break;
		default:
			
			break;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[sharer release];
	[shareButtonPressed release];
	[shareBtnSMS release];
	[shareBtnCopy release];
	[shareBtnEmail release];
	[shareBtnFacebook release];
	[shareBtnTwitter release];
	[textView release];
	[charCounter release];
    [super dealloc];
}


@end
