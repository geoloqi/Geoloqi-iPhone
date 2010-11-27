//
//  LQLayerViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQLayerViewController.h"
#import "LQLayerDetailViewController.h"
#import "LQLayerCellView.h"
#import "GLAuthenticationManager.h"
#import "CJSONDeserializer.h"

@implementation LQLayerViewController

@synthesize layerCell;
@synthesize featuredLayers, yourLayers;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];

	[[GLAuthenticationManager sharedManager] callAPIPath:@"layer/app_list" 
												  method:@"GET" 
									  includeAccessToken:YES
									   includeClientCred:NO
											  parameters:nil
												callback:[self loadLayersCallback]];
}

- (GLHTTPRequestCallback)loadLayersCallback {
	if (loadLayersCallback) return loadLayersCallback;
	NSLog(@"Making a new loadLayersCallback block");
	return loadLayersCallback = [^(NSError *error, NSString *responseBody) {
		NSLog(@"Layer list loaded");
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for layer/app_list) \"%@\": %@", responseBody, err);
			[[GLAuthenticationManager sharedManager] errorProcessingAPIRequest];
			return;
		}
		
		if ([[res objectForKey:@"your_layers"] isKindOfClass:[NSArray class]])
		{
			NSLog(@"Found your layers: %@", [res objectForKey:@"your_layers"]);

			self.yourLayers = [res objectForKey:@"your_layers"];
			self.featuredLayers	= [res objectForKey:@"featured_layers"];
			[layerTable reloadData];
			
			return;
		}
		else {
			NSLog(@"Not the expected response");
		}
	} copy];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}
*/

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		default:
			return 44;
	}
	return 44;
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [featuredLayers count];
		case 1:
			return [yourLayers count];
		default:
			return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Featured Layers";
		case 1:
			return @"Your Layers";
	}
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *myIdentifier = @"MyIdentifier";
	myIdentifier = @"tblCellView";
	
	LQLayerCellView *cell = (LQLayerCellView *)[tableView dequeueReusableCellWithIdentifier:myIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LQLayerCellView" owner:self options:nil];
		cell = layerCell;
	}

	NSDictionary *layer = [self getLayerAtIndexPath:indexPath];
	
	[cell setLabelText:[layer objectForKey:@"name"]];
	[cell setLayerImage:[layer objectForKey:@"icon"]];
	[cell setDescpText:[layer objectForKey:@"description"]];
	 
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Selected a layer");
	
	//LQLayerDetailViewController *detailController = [[LQLayerDetailViewController alloc] initWithNibName:@"LQLayerDetailViewController" bundle:nil];

	NSDictionary *layer = [self getLayerAtIndexPath:indexPath];
	LQLayerDetailViewController *detailController = [[LQLayerDetailViewController alloc] initWithLayer:layer];
	
	[self.navigationController pushViewController:detailController animated:YES];

	[detailController release];

	/*
	[detailController setTitle:@"USGS Earthquakes"];
	[detailController setLayerName:@"USGS Earthquakes"];
	[detailController setLayerDescription:@"By Geoloqi.com"];
	[detailController setLayerImage:@"http://geoloqi.local/icon.png"];
	[detailController setLayerHTMLView:@"http://fakeapi.local/layer/11111"];
	detailController.layerID = @"11111";
	*/
	
	[tableView deselectRowAtIndexPath: indexPath animated:YES];
}

- (NSDictionary *) getLayerAtIndexPath:(NSIndexPath *)indexPath {
	 NSDictionary *layer;
	 
	 switch(indexPath.section) {
		 case 0:
			 layer = [featuredLayers objectAtIndex:indexPath.row];
			 break;
		 case 1:
			 layer = [yourLayers objectAtIndex:indexPath.row];
			 break;
		 default:
			 layer = [NSDictionary dictionary];
			 break;
	 }
	 return layer;
}
	 
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.layerCell = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[layerCell dealloc];
	[featuredLayers release];
	[yourLayers release];
	[loadLayersCallback release];
    [super dealloc];
}


@end
