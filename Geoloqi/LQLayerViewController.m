//
//  LQLayerViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQLayerViewController.h"
#import "LQLayerCellView.h"

@implementation LQLayerViewController

@synthesize layerCell;

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

	//layerCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	//layerCell.selectionStyle = UITableViewCellSelectionStyleNone;
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
			// TODO: count the actual number of layers
			return 4;
		case 1:
			return 3;
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
	
	[cell setLabelText:@"USGS Earthquakes"];
	[cell setProductImage:@"Icon.png"];
	[cell setDescpText:@"Get alerts of earthquakes near you"];
	return cell;
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
	[layerCell dealloc];
    [super dealloc];
}


@end
