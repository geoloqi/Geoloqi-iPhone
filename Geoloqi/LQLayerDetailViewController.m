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
#import "SHK.h"

@implementation LQLayerDetailViewController

@synthesize layer;
@synthesize delegate;

- (id)initWithLayer:(NSMutableDictionary *)_layer {

	if (self = [self initWithNibName:@"LQLayerDetailViewController" bundle:nil]) {
		self.layer = _layer;
	}
	return self;
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
	
	[[PKHTTPCachedImage sharedInstance] setImageForView:layerImg withURL:[layer objectForKey:@"icon"]];
	
	NSString *model = [[NSString stringWithFormat:@"%@+%@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"%@", model);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_token=%@&model=%@", [layer objectForKey:@"url"], [[Geoloqi sharedInstance] accessToken], model]]];
	[webView loadRequest:request];
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
	}else{
		[layer setObject:@"0" forKey:@"subscribed"];
		[[Geoloqi sharedInstance] unSubscribeFromLayer:[layer objectForKey:@"layer_id"] callback:[self layerSubscribeCallback]];
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
			msg = @"Subscribed!";
		}else{
			msg = @"Unsubscribed";
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
