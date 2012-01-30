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
#import "LQShareTwitterConnectViewController.h"
#import "LQShareFacebookConnectViewController.h"
#import "SHKActivityIndicator.h"
#import "CJSONDeserializer.h"

@implementation LQShareViewController2

@synthesize navigationItem;
@synthesize shareButtonPressed;
@synthesize activityIndicator;
@synthesize sharer;
@synthesize shareURL, shareMessage, shareMinutes;

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

- (id)initWithURL:(NSURL *)url 
	   andMessage:(NSString *)message 
	  forDuration:(NSNumber *)minutes 
	   canTwitter:(BOOL)twitter
	  canFacebook:(BOOL)facebook {

	self = [super initWithNibName:nil bundle:nil];
	if(self) {
		self.shareURL = url;
		self.shareMessage = message;
		self.shareMinutes = minutes;
		canFacebook = facebook;
		canTwitter = twitter;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture.png"]]];
	
	if([self.shareMessage length] == 0){
		self.shareMessage = @"Heading out! Track me on Geoloqi!";
	}
	
	textView.text = [NSString stringWithFormat:@"%@ %@", self.shareMessage, self.shareURL];

	[gAppDelegate makeLQButton:shareBtnEmail];
	[gAppDelegate makeLQButton:shareBtnSMS];
	[gAppDelegate makeLQButton:shareBtnTwitter];
	[gAppDelegate makeLQButton:shareBtnFacebook];
	[gAppDelegate makeLQButton:shareBtnCopy];
}

- (LQShareMethod)stringToShareMethod:(NSString *)str {
	LQShareMethod method = LQShareMethodUnknown;
	if([str isEqualToString:@"Email"]){
		method = LQShareMethodEmail;
	} else if([str isEqualToString:@"SMS"]){
		method = LQShareMethodSMS;
	} else if([str isEqualToString:@"Tweet"]){
		method = LQShareMethodTwitter;
	} else if([str isEqualToString:@"Post to Facebook"]){
		method = LQShareMethodFacebook;
	} else if([str isEqualToString:@"Copy Link"]){
		method = LQShareMethodCopy;
	}
	return method;
}

/*
 * Hide the keyboard when the user presses "Done". This also means it's impossible to type a newline into the box.
 */
- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqual:@"\n"]) {
		[_textView resignFirstResponder];
		return NO;
	}
	return YES;
}

- (IBAction)backWasTapped {
	[view_parentViewController(self) dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneWasTapped {
	[view_parentViewController(view_parentViewController(self)) dismissModalViewControllerAnimated:YES];
}

- (IBAction)shareServiceButtonWasTapped:(id)sender {
	[self shareLinkVia:[self stringToShareMethod:[[sender titleLabel] text]]];
}

- (void)shareLinkVia:(LQShareMethod)method {
	
	switch(method){
		case LQShareMethodEmail:
			sharer = [[LQShareMail alloc] initWithController:self];
			[sharer shareURL:self.shareURL withMessage:self.shareMessage minutes:self.shareMinutes];
			break;
		case LQShareMethodSMS:
			sharer = [[LQShareSMS alloc] initWithController:self];
			[sharer shareURL:self.shareURL withMessage:self.shareMessage minutes:self.shareMinutes];
			break;
		case LQShareMethodTwitter:
			self.activityIndicator.alpha = 1.0f;

			if(canTwitter) {
				self.activityIndicator.alpha = 1.0f;
				// self.sendButton.enabled = NO;
				
				// Try to post the tweet!
				[[Geoloqi sharedInstance] postToTwitter:textView.text
											   callback:self.tweetPostedCallback];
				
			} else {
				LQShareTwitterConnectViewController *twitterConnectController = [[LQShareTwitterConnectViewController alloc] init];
				// Give the view a pointer to the boolean here so it can update it when it finishes
				twitterConnectController.delegate = self;
				[self presentModalViewController:twitterConnectController animated:YES];
				[twitterConnectController release];
			}
			
			break;
		case LQShareMethodFacebook:
			self.activityIndicator.alpha = 1.0f;
			//self.sendButton.enabled = NO;

			if(canFacebook) {
				self.activityIndicator.alpha = 1.0f;
				// self.sendButton.enabled = NO;
				
				// Try to post the update!
				[[Geoloqi sharedInstance] postToFacebook:textView.text
													 url:[self.shareURL absoluteString]
												callback:self.facebookPostedCallback];
			} else {
				LQShareFacebookConnectViewController *facebookConnectController = [[LQShareFacebookConnectViewController alloc] init];
				facebookConnectController.delegate = self;
				[self presentModalViewController:facebookConnectController animated:YES];
				[facebookConnectController release];
			}
			
			break;
		case LQShareMethodCopy:
			[[UIPasteboard generalPasteboard] setString:self.shareURL.absoluteString];
			[LQShareService linkWasSent:@"Link Copied" minutes:self.shareMinutes];
			[gAppDelegate.mapViewController dismissModalViewControllerAnimated:YES];
			break;
		default:
			
			break;
	}
}

- (void)userConnectedTwitter {
	canTwitter = YES;
	
	// Tweet now! The modal windows will be closed after it succeeds.
	[[Geoloqi sharedInstance] postToTwitter:textView.text
								   callback:self.tweetPostedCallback];
}

- (void)userConnectedFacebook {
	canFacebook = YES;

	// Post to facebook now! The modal windows will be closed after it succeeds.
	[[Geoloqi sharedInstance] postToFacebook:textView.text
										 url:[self.shareURL absoluteString]
									callback:self.facebookPostedCallback];
}

- (LQHTTPRequestCallback)tweetPostedCallback {
	if (tweetPostedCallback) return tweetPostedCallback;
	return tweetPostedCallback = [^(NSError *error, NSString *responseBody) {
		
		self.activityIndicator.alpha = 0.0f;
		// self.sendButton.enabled = YES;
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		
		if (!res || [res objectForKey:@"error"] != nil) {
			[[SHKActivityIndicator currentIndicator] displayCompleted:@"Twitter Error!"];
			[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✕"];
			[gAppDelegate.mapViewController dismissModalViewControllerAnimated:YES];
		}else{
//			[[SHKActivityIndicator currentIndicator] displayCompleted:@"Tweeted!"];
			[LQShareService linkWasSent:@"Posted to Twitter" minutes:self.shareMinutes];
			[gAppDelegate.mapViewController dismissModalViewControllerAnimated:YES];
		}
	} copy];
}

- (LQHTTPRequestCallback)facebookPostedCallback {
	if (facebookPostedCallback) return facebookPostedCallback;
	return facebookPostedCallback = [^(NSError *error, NSString *responseBody) {
		
		self.activityIndicator.alpha = 0.0f;
		// self.sendButton.enabled = YES;
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		
		if (!res || [res objectForKey:@"error"] != nil) {
			[[SHKActivityIndicator currentIndicator] displayCompleted:@"Facebook Error!"];
			[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✕"];
			[gAppDelegate.mapViewController dismissModalViewControllerAnimated:YES];
		}else{
//			[[SHKActivityIndicator currentIndicator] displayCompleted:@"Posted!"];
			[LQShareService linkWasSent:@"Posted to Facebook" minutes:self.shareMinutes];
			[gAppDelegate.mapViewController dismissModalViewControllerAnimated:YES];
		}
	} copy];
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
