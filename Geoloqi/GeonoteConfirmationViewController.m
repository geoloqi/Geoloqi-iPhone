//
//  GeonoteConfirmationViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GeonoteConfirmationViewController.h"
#import "Geonote.h"

@implementation GeonoteConfirmationViewController

@synthesize geonote;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    geonoteSummaryLabel.text = [self.geonote description];
}

- (void)dealloc
{
    [geonote release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction)dismiss:(id)sender
{
    UITabBarController *appTabBarController = ((UITabBarController *)self.parentViewController.parentViewController);
    UINavigationController *geonoteNavigationController = ((UINavigationController *)appTabBarController.selectedViewController);
    
    [geonoteNavigationController popToRootViewControllerAnimated:NO];
    [appTabBarController dismissModalViewControllerAnimated:YES];
}

@end