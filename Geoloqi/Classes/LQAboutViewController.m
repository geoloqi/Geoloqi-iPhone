//
//  LQAbout.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/18/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQAboutViewController.h"
#import "LQConstants.h"

@implementation LQAboutViewController

//@synthesize webView;

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
	
	firstLoad = YES;
    webView.delegate = self;
    webView.alpha = 0.0;
	
	NSString *url = [NSString stringWithFormat:@"%@/about/iphone?geoloqi_version=%@", LQ_WEB_ROOT, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	if (firstLoad) {
		firstLoad = NO;
		[UIView beginAnimations:@"webView" context:nil];
		webView.alpha = 1.0;
		[UIView commitAnimations];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)doneButtonWasTapped:(UIBarButtonItem *)button {
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
//	[webView dealloc];
    [super dealloc];
}


@end
