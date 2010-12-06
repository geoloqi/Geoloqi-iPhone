//
//  LQLayerDetailViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/25/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "CJSONDeserializer.h"
#import "LQLayerDetailViewController.h"
#import "SHK.h"

@implementation LQLayerDetailViewController

@synthesize layer;

- (id)initWithLayer:(NSDictionary *)_layer {
	if (self = [self initWithNibName:@"LQLayerDetailViewController" bundle:nil]) {
		self.layer = _layer;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	layerName.text = [layer objectForKey:@"name"];
	layerDescription.text = [layer objectForKey:@"description"];
	layerImg.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [layer objectForKey:@"icon"]]]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[layer objectForKey:@"url"]]];
	[webView loadRequest:request];
	[activateButton setTitle:@"Subscribe" forState:UIControlStateNormal];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)tappedActivate:(id)sender
{
	NSLog(@"User tapped activate on layer ID %@!", [layer objectForKey:@"layer_id"]);
    [[Geoloqi sharedInstance] subscribeToLayer:[layer objectForKey:@"layer_id"] callback:[self layerActivatedCallback]];
}

- (LQHTTPRequestCallback)layerActivatedCallback {
	if (layerActivatedCallback) return layerActivatedCallback;
	return layerActivatedCallback = [^(NSError *error, NSString *responseBody) {
		NSLog(@"Layer activated!");
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for layer/subscribe) \"%@\": %@", responseBody, err);
			[[Geoloqi sharedInstance] errorProcessingAPIRequest];
			return;
		}
		
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Subscribed!"];

		activateButton.titleLabel.text = @"Subscribed";
		
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
	[layer release];
	[layerImg release];
	[layerName release];
	[layerDescription release];
	[webView release];
    [super dealloc];
}


@end
