//
//  LQTwitterAuthViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-26.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQTwitterAuthViewController.h"
#import "LQConstants.h"
#import "Geoloqi.h"
#import "SHKActivityIndicator.h"

@implementation LQTwitterAuthViewController

@synthesize webView;
@synthesize activityIndicator;

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
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																						   target:self 
																						   action:@selector(cancel)] autorelease];
		
	self.title = NSLocalizedString(@"Log in with Twitter", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(authenticationDidFail:) 
												 name:LQAuthenticationFailedNotification 
											   object:nil];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/connect/twitter?client_id=%@", LQ_WEB_ROOT, LQ_OAUTH_CLIENT_ID]]];
	[webView loadRequest:request];
}

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)w {
	self.activityIndicator.alpha = 0.0;

	// When the auth cycle is complete, the browser is redirected 
	// to /connect/twitter_app#auth_code
	if([w.request.URL.path isEqualToString:@"/connect/twitter_app"]){
		self.activityIndicator.alpha = 1.0;
		// Attempt to use the auth code and get an access token. This will either succeed and the app delegate's
		// listener will catch the authentication success, or it will fail and the fail method below will be called.
		[[Geoloqi sharedInstance] authenticateWithAuthCode:w.request.URL.fragment];
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	self.activityIndicator.alpha = 1.0;
}

- (void)authenticationDidFail:(NSNotificationCenter *)notification {
	self.activityIndicator.alpha = 0.0;
	[[SHKActivityIndicator currentIndicator] displayCompleted:@"Login Failed!"];
	[[SHKActivityIndicator currentIndicator] setCenterMessage:@"✕"];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	self.activityIndicator.alpha = 0.0;
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationFailedNotification 
                                                  object:nil];
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
	[webView release];
	
    [super dealloc];
}


@end
