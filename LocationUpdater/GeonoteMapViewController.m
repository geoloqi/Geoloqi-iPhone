//
//  GeonoteMapViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GeonoteMapViewController.h"
#import "GeonoteRadiusViewController.h"
#import "Geonote.h"

@implementation GeonoteMapViewController

@synthesize geonote;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = searchBar;
    
    nextButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Choose a location";
    
    if ( ! self.geonote.location)
        self.geonote.location = gAppDelegate.locationUpdateManager.lastKnownLocation;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Location";
    
    [searchBar resignFirstResponder];
}

- (void)dealloc
{
    [geonote release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction)tappedNext:(id)sender
{
    GeonoteRadiusViewController *radiusViewController = [[[GeonoteRadiusViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    radiusViewController.geonote = self.geonote;
    
    [self.navigationController pushViewController:radiusViewController animated:YES];
}

#pragma mark -

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [aSearchBar resignFirstResponder];
    
    NSString *query = aSearchBar.text;
    
    NSLog(@"search on %@", query);
    
    nextButton.enabled = YES;
}

@end