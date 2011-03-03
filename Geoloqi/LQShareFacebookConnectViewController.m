//
//  LQShareFacebookConnectViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/17/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareFacebookConnectViewController.h"
#import "LQConstants.h"
#import "Geoloqi.h"

@implementation LQShareFacebookConnectViewController

@synthesize webView;
@synthesize cancelButton;
@synthesize activityIndicator;
@synthesize delegate;

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
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/post/facebook_connect?oauth_token=%@", LQ_WEB_ROOT, [[Geoloqi sharedInstance] accessToken]]]];
	[self.webView loadRequest:request];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)webViewDidFinishLoad:(UIWebView *)w {
	self.activityIndicator.alpha = 0.0;
	NSLog(@"Finished loading web: %@", w.request.URL);
	// Complete when the query starts with "finished"
	if([w.request.URL.query hasPrefix:@"oauth_callback"] && [w.request.URL.path hasSuffix:@"facebook_connect"]) {
		if(self.delegate && [self.delegate respondsToSelector:@selector(userConnectedFacebook)]){
			[self.delegate userConnectedFacebook];
		}
	}
}

- (void)webViewDidStartLoad:(UIWebView *)w {     
	self.activityIndicator.alpha = 1.0;
}


- (void)cancelWasTapped:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
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
    [super dealloc];
}


@end
