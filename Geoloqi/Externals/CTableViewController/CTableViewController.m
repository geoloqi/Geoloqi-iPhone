//
//  CTableViewController.m
//  TouchCode
//
//  Created by Jonathan Wight on 2/25/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CTableViewController.h"

// UITableViewController
// Creates a table view with the correct dimensions and autoresizing, setting the datasource and delegate to self.
// In -viewWillAppear:, it reloads the table's data if it's empty. Otherwise, it deselects all rows (with or without animation).
// In -viewDidAppear:, it flashes the table's scroll indicators.
// Implements -setEditing:animated: to toggle the editing state of the table.

@implementation CTableViewController

@synthesize tableView = outletTableView;
@synthesize initialStyle;
@synthesize clearsSelectionOnViewWillAppear;

- (id)init
{
if ((self = [super initWithNibName:NULL bundle:NULL]) != NULL)
	{
	initialStyle = UITableViewStylePlain;
	clearsSelectionOnViewWillAppear = YES;
	}
return(self);
}

- (void)dealloc
{
outletTableView.delegate = NULL;
outletTableView.dataSource = NULL;
[outletTableView release];
outletTableView = NULL;
//
[super dealloc];
}

#pragma mark -

- (UIBarButtonItem *)addButtonItem
{
if (addButtonItem == NULL)
    {
    addButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)] autorelease];
    }
return(addButtonItem);
}

#pragma mark -

- (void)loadView
{
[super loadView];
//
if (self.view == NULL)
	{
	CGRect theViewFrame = [[UIScreen mainScreen] applicationFrame];
	UIView *theView = [[[UITableView alloc] initWithFrame:theViewFrame] autorelease];
	theView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	//
	self.view = theView;
	}

if (self.tableView == NULL)
	{
	if ([self.view isKindOfClass:[UITableView class]])
		{
		self.tableView = (UITableView *)self.view;
		}
	else
		{
		CGRect theViewFrame = self.view.bounds;
		UITableView *theTableView = [[[UITableView alloc] initWithFrame:theViewFrame style:self.initialStyle] autorelease];
		theTableView.delegate = self;
		theTableView.dataSource = self;
		theTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		//
		[self.view addSubview:theTableView];
		self.tableView = theTableView;
		}
	}
}

- (void)viewDidUnload
{
[super viewDidUnload];
//
outletTableView.delegate = NULL;
outletTableView.dataSource = NULL;
[outletTableView release];
outletTableView = NULL;
}

- (void)viewWillAppear:(BOOL)inAnimated
{
[super viewWillAppear:inAnimated];
//
[self.tableView reloadData];
//
if (self.clearsSelectionOnViewWillAppear == YES)
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:inAnimated];
}

- (void)viewDidAppear:(BOOL)inAnimated
{
[super viewDidAppear:inAnimated];
//
[self.tableView flashScrollIndicators];
}

- (void)setEditing:(BOOL)inEditing animated:(BOOL)inAnimated
{
[super setEditing:inEditing animated:inAnimated];
//
[self.tableView setEditing:inEditing animated:inAnimated];

self.addButtonItem.enabled = !inEditing;
}

- (IBAction)add:(id)inSender
{
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
return(0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
return(NULL);
}

@end

