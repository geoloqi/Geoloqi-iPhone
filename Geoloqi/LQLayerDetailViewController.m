//
//  LQLayerDetailViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/25/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "CJSONDeserializer.h"
#import "LQLayerDetailViewController.h"
#import "PKHTTPCachedImage.h"
#import "SHKActivityIndicator.h"

@implementation LQLayerDetailViewController

@synthesize layer;
@synthesize delegate;
@synthesize activityIndicator;

- (id)initWithLayer:(NSMutableDictionary *)_layer {

	if (self = [self initWithNibName:@"LQLayerDetailViewController" bundle:nil]) {
		self.layer = _layer;
	}
	return self;
}

- (void)loadWebView {
	NSString *model = [[NSString stringWithFormat:@"%@+%@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?layer_id=%@&oauth_token=%@&model=%@", [layer objectForKey:@"url"], [layer objectForKey:@"layer_id"], [[Geoloqi sharedInstance] accessToken], model]]];
	[webView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	layerName.text = [layer objectForKey:@"name"];
	layerDescription.text = [layer objectForKey:@"description"];
	
	if([[NSString stringWithFormat:@"%@", [layer objectForKey:@"subscribed"]] isEqualToString:@"1"]) {
		subscribeSwitch.on = YES;
	}else{
		subscribeSwitch.on = NO;
	}
	
	if([[NSString stringWithFormat:@"%@", [layer objectForKey:@"type"]] isEqualToString:@"normal"]) {
		subscribeSwitch.hidden = NO;
	}else{
		subscribeSwitch.hidden = YES;
	}
	
	[[PKHTTPCachedImage sharedInstance] setImageForView:layerImg withURL:[layer objectForKey:@"icon"]];

	[self loadWebView];
}

- (IBAction)didClickLayerIcon:(id)sender {
	[self loadWebView];
}

- (BOOL)webView:(UIWebView *)w shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *requestString = [[request URL] absoluteString];
	NSArray *components = [requestString componentsSeparatedByString:@":"];

	if ([components count] >= 2 && 
		[(NSString *)[components objectAtIndex:0] isEqualToString:@"geoloqi-app"] &&
		[(NSString *)[components objectAtIndex:1] isEqualToString:@"layer"]) 
	{
		NSString *msg;
		if([[components objectAtIndex:2] isEqualToString:@"subscribed"]) {
			msg = @"Activated!";
			subscribeSwitch.on = YES;
		} else {
			msg = @"Deactivated";
			subscribeSwitch.on = NO;
		}
		[[SHKActivityIndicator currentIndicator] displayCompleted:msg];
		return NO;
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)w {
	self.activityIndicator.alpha = 0.0;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {     
	self.activityIndicator.alpha = 1.0;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)subscribeChanged:(UISwitch *)sender
{
	NSLog(@"User changed subscribe switch on layer ID %@!", [layer objectForKey:@"layer_id"]);
	if([sender isOn]){
		[layer setObject:@"1" forKey:@"subscribed"];
		[[Geoloqi sharedInstance] subscribeToLayer:[layer objectForKey:@"layer_id"] callback:[self layerSubscribeCallback]];
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"if(typeof geoloqi_userDidSubscribeToLayer != \"undefined\") { "
									"geoloqi_userDidSubscribeToLayer(\"%@\"); }", [layer objectForKey:@"layer_id"]]];
	}else{
		[layer setObject:@"0" forKey:@"subscribed"];
		[[Geoloqi sharedInstance] unSubscribeFromLayer:[layer objectForKey:@"layer_id"] callback:[self layerSubscribeCallback]];
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"if(typeof geoloqi_userDidUnsubscribeFromLayer != \"undefined\") { "
														 "geoloqi_userDidUnsubscribeFromLayer(\"%@\"); }", [layer objectForKey:@"layer_id"]]];
	}
	
    if( [self.delegate respondsToSelector: @selector( layerDetailViewControllerDidUpdateLayer: )] ){
        [self.delegate layerDetailViewControllerDidUpdateLayer: self.layer];
    }
}

- (LQHTTPRequestCallback)layerSubscribeCallback {
	if (layerSubscribeCallback) return layerSubscribeCallback;
	return layerSubscribeCallback = [^(NSError *error, NSString *responseBody) {
		NSLog(@"Layer subscription response");
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for layer/subscribe) \"%@\": %@", responseBody, err);
			[[Geoloqi sharedInstance] errorProcessingAPIRequest];
			return;
		}

		NSString* msg;
		if([[NSString stringWithFormat:@"%@", [res objectForKey:@"subscribed"]] isEqualToString:@"1"]){
			msg = @"Activated!";
		}else{
			msg = @"Deactivated";
		}
		
		[[SHKActivityIndicator currentIndicator] displayCompleted:msg];
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
	[layerSubscribeCallback release];
    [super dealloc];
}


@end
