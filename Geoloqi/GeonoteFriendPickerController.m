//
//  GeonoteFriendPickerController.m
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GeonoteFriendPickerController.h"
#import "GeonoteMapViewController.h"
#import "Geonote.h"

@implementation GeonoteFriendPickerController

@synthesize geonote;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Choose a friend";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Friend!";
}

- (void)dealloc
{
    [geonote release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction)tappedNext:(id)sender
{
    self.geonote = [[[Geonote alloc] init] autorelease];
    self.geonote.friend = @"friend name here";
    
    GeonoteMapViewController *mapViewController = [[[GeonoteMapViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    mapViewController.hidesBottomBarWhenPushed = YES;
    mapViewController.geonote = self.geonote;
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}

@end