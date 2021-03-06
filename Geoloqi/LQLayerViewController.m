//
//  LQLayerViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQLayerViewController.h"
#import "LQLayerCellView.h"
#import "CJSONDeserializer.h"

@implementation LQLayerViewController

@synthesize layerCell;
@synthesize featuredLayers, yourLayers, activeLayers, inactiveLayers;
@synthesize selectedIndexPath;

- (void)parseLayerJSON:(NSString *)data {
    NSError *err = nil;
    NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[data dataUsingEncoding:NSUTF8StringEncoding] error:&err];

    if (!res || [res objectForKey:@"error"] != nil) {
        NSLog(@"Error deserializing response (for layer list) \"%@\": %@", data, err);
        return;
    }
    
    if ([[res objectForKey:@"your"] isKindOfClass:[NSArray class]])
    {
        NSLog(@"Parsed layer list. Reloading table.");
        self.yourLayers = [res objectForKey:@"your"];
        self.featuredLayers = [res objectForKey:@"featured"];
        self.inactiveLayers = [res objectForKey:@"inactive"];
        self.activeLayers = [res objectForKey:@"active"];
        [self.tableView reloadData];
        
        return;
    }
    else {
        NSLog(@"Not the expected response");
    }
}

- (void)saveLayerListToDisk:(NSString *)data
{
    NSArray       *myPathList        =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString      *myPath            =  [myPathList  objectAtIndex:0];
    NSError       **err;

    NSLog(@"Storing layer list to disk");
    
    myPath = [myPath stringByAppendingPathComponent:@"layers.json"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:myPath])
    [[NSFileManager defaultManager] createFileAtPath:myPath contents:nil attributes:nil];
    [data writeToFile:myPath atomically:NO encoding:NSUTF8StringEncoding error:err];    
}

- (NSString *)retrieveLayerListFromFile
{
    NSArray       *myPathList        =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString      *myPath            =  [myPathList  objectAtIndex:0];
    NSError       **err;
    
    NSLog(@"Retrieving layer list from disk");
    
    myPath = [myPath stringByAppendingPathComponent:@"layers.json"];
    if([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        return [NSString stringWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:err];
    else
        return nil;
}

- (LQHTTPRequestCallback)loadLayersCallback {
	if (loadLayersCallback) return loadLayersCallback;
	return loadLayersCallback = [^(NSError *error, NSString *responseBody) {
		
        lastRefresh = [[NSDate alloc] init];
        [self parseLayerJSON:responseBody];
        [self stopLoading];
        [self saveLayerListToDisk:responseBody];
	} copy];
}

- (void)refreshLayerList {
    NSLog(@"refreshLayerList called");
    [[Geoloqi sharedInstance] layerAppList:[self loadLayersCallback]];
}	

- (void)loadLayerList {
    NSString *layerList;
    NSLog(@"loadLayerList called");
    if((layerList=[self retrieveLayerListFromFile]) == nil) {
        NSLog(@"Fetching new layer list");
        // The first time they load the list there will be no file. Make it look like they hit the "refresh" pulldown
        [self refresh];
    } else {
        NSLog(@"Using cached layer list");
        [self parseLayerJSON:layerList];
    }
}
	

- (void)viewDidLoad {
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture.png"]]];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Layer list view will appear");
    if(lastRefresh == nil || [lastRefresh timeIntervalSinceNow] < -300) {
        [self refreshLayerList];
    } else {
        [self loadLayerList];
        [self.tableView reloadData];
    }
}

// Called by the PullRefresh view controller, should only start retrieving data
- (void)refresh {
	[self refreshLayerList];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}
*/


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		default:
			return 65;
	}
	return 65;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [activeLayers count];
		case 1:
			return [yourLayers count];
		case 2:
			return [inactiveLayers count];
		case 3:
			return [featuredLayers count];
		default:
			return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if([self tableView:tableView numberOfRowsInSection:section] == 0) {
		return @"";
	}
	
	switch (section) {
		case 0:
			return @"Active Layers";
		case 1:
			return @"Your Layers";
		case 2:
			return @"Inactive Layers";
		case 3:
			return @"Featured Layers";
		default:
			return @"";
	}
	return @"";
}

/********************************************************************************
 * Customize the table group label colors. There is no way to do this with
 * the built in label, so you have to make a separate view for the header
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil
			&& ![[self tableView:tableView titleForHeaderInSection:section] isEqualToString:@""]) {
        return 36;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil && ![sectionTitle isEqualToString:@""]) {
        return nil;
    }
	
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, -1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
	
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    [view autorelease];
    [view addSubview:label];
	
    return view;
}
/********************************************************************************/

- (NSDictionary *)getLayer:(NSIndexPath *)indexPath {
    NSDictionary *layer;
	
	switch(indexPath.section) {
		case 0:
            layer = [activeLayers objectAtIndex:indexPath.row];
            break;
		case 1:
            layer = [yourLayers objectAtIndex:indexPath.row];
            break;
		case 2:
            layer = [inactiveLayers objectAtIndex:indexPath.row];
            break;
		case 3:
            layer = [featuredLayers objectAtIndex:indexPath.row];
            break;
		default:
            layer = [NSDictionary dictionary];
			break;
	}

    return layer;    
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
	
	NSMutableDictionary *layer = [self getLayerAtIndexPath:indexPath];
	LQLayerDetailViewController *detailController = [[LQLayerDetailViewController alloc] initWithLayer:layer];
	detailController.delegate = self;
	
	self.selectedIndexPath = indexPath;

	[self.navigationController pushViewController:detailController animated:YES];

	[detailController release];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableDictionary *) getLayerAtIndexPath:(NSIndexPath *)indexPath {
	 NSMutableDictionary *layer = nil;
	 
	 switch(indexPath.section) {
		 case 0:
			 layer = [[[activeLayers objectAtIndex:indexPath.row] mutableCopy] autorelease];
			 break;
		 case 1:
			 layer = [[[yourLayers objectAtIndex:indexPath.row] mutableCopy] autorelease];
			 break;
		 case 2:
			 layer = [[[inactiveLayers objectAtIndex:indexPath.row] mutableCopy] autorelease];
			 break;
		 case 3:
			 layer = [[[featuredLayers objectAtIndex:indexPath.row] mutableCopy] autorelease];
			 break;
		 default:
			 layer = [NSMutableDictionary dictionary];
			 break;
	 }
	 return layer;
}
	
- (void) layerDetailViewControllerDidUpdateLayer: (NSMutableDictionary*) layer {
	NSLog(@"%@", self.selectedIndexPath);
	
	NSArray *theArray = nil;
	switch(self.selectedIndexPath.section){
		case 0:
			theArray = activeLayers;
			break;
		case 1:
			theArray = yourLayers;
			break;
		case 2:
			theArray = inactiveLayers;
			break;
		default:
			theArray = featuredLayers;
			break;
	}
	
	lastRefresh = nil;
	[self refreshLayerList];
	
	for( NSMutableDictionary *iLayer in theArray )
	{
		if([[iLayer objectForKey:@"layer_id"] isEqualToString: [layer objectForKey:@"layer_id"]]){
			[iLayer setValue:[layer objectForKey:@"subscribed"] forKey:@"subscribed"];
		}
	}
	
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
	[layerCell release];
	[featuredLayers release];
	[yourLayers release];
	[activeLayers release];
	[inactiveLayers release];
	[loadLayersCallback release];
	[selectedIndexPath release];
	[lastRefresh release];
    [super dealloc];
}


@end
