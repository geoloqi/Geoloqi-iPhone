//
//  GeonoteMessageViewController.m
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import "GeonoteMessageViewController.h"
#import "GeonoteConfirmationViewController.h"
#import "Geonote.h"

@implementation GeonoteMessageViewController

@synthesize geonote;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Enter your message";
    
    if ( ! self.geonote.radius)
        self.geonote.radius = 120;
}

- (void)dealloc
{
    [geonote release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction)tappedFinish:(id)sender
{
    [textView resignFirstResponder];
    
    GeonoteConfirmationViewController *confirmationViewController = [[[GeonoteConfirmationViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    confirmationViewController.geonote = self.geonote;
    
    UINavigationController *wrapper = [[[UINavigationController alloc] initWithRootViewController:confirmationViewController] autorelease];

    confirmationViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                                                     style:UIBarButtonItemStyleDone 
                                                                                                    target:confirmationViewController
                                                                                                    action:@selector(dismiss:)] autorelease];
    
    [self.navigationController presentModalViewController:wrapper animated:YES];
}

#pragma mark -

- (void)textViewDidBeginEditing:(UITextView *)aTextView
{
    if ( ! self.geonote.text)
        aTextView.text = @"";
}

- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [aTextView resignFirstResponder];
        
        self.geonote.text = aTextView.text;
        
        return NO;
    }
    
    return YES;
}

@end