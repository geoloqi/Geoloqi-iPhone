//
//  LQLayerDetailViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/25/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GLAuthenticationManager.h"
#import "CJSONDeserializer.h"
#import "LQLayerDetailViewController.h"
#import "SHK.h"

@implementation LQLayerDetailViewController

@synthesize layerID;

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
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)setLayerName:(NSString *)_text {
	NSLog(@"Setting layer name %@", _text);
	layerName.text = _text;
}

- (void)setLayerDescription:(NSString *)_text {
	layerDescription.text = _text;
}

- (void)setLayerImage:(NSString *)_url {
	layerImg.image = [[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: _url]]] retain];
}

- (void)setLayerHTMLView:(NSString *)_url {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
	[webView loadRequest:request];
}

- (void)setButtonText:(NSString *)_text {
	[activateButton setTitle:_text forState:UIControlStateNormal];
}

- (IBAction)tappedActivate:(id)sender
{
	NSLog(@"User tapped activate on layer ID %@!", layerID);
	[[GLAuthenticationManager sharedManager] callAPIPath:[NSString stringWithFormat:@"layer/subscribe/%@", layerID]
												  method:@"GET"
									  includeAccessToken:YES
									   includeClientCred:NO
											  parameters:nil
												callback:[self layerActivatedCallback]];
}

- (GLHTTPRequestCallback)layerActivatedCallback {
	if (layerActivatedCallback) return layerActivatedCallback;
	return layerActivatedCallback = [^(NSError *error, NSString *responseBody) {
		NSLog(@"Layer activated!");
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for layer/subscribe) \"%@\": %@", responseBody, err);
			[[GLAuthenticationManager sharedManager] errorProcessingAPIRequest];
			return;
		}
		
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Subscribed!"];

		[self setButtonText:@"Subscribed"];
		
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
	[layerImg release];
	[layerName release];
	[layerDescription release];
	[webView release];
    [super dealloc];
}


@end
