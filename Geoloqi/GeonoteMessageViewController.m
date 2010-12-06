//
//  GeonoteMessageViewController.m
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GeonoteMessageViewController.h"
#import "Geonote.h"
#import "CJSONDeserializer.h"
#import "SHKActivityIndicator.h"

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
    [geonoteSentCallback release];
    [super dealloc];
}

#pragma mark -

- (IBAction)tappedFinish:(id)sender
{
	self.geonote.text = [NSString stringWithString:textView.text];
	NSLog(@"Geonote: %@", [self.geonote description]);
	 
    [[Geoloqi sharedInstance] createGeonote:textView.text 
                                   latitude:self.geonote.latitude 
                                  longitude:self.geonote.longitude 
                                     radius:self.geonote.radius
                                   callback:[self geonoteSentCallback]];
    
}

- (LQHTTPRequestCallback)geonoteSentCallback {
	if (geonoteSentCallback) return geonoteSentCallback;
	NSLog(@"Making a new geonoteSentCallback block");
	return geonoteSentCallback = [^(NSError *error, NSString *responseBody) {
		NSLog(@"Geonote sent!");

		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for geonote/create) \"%@\": %@", responseBody, err);
			[[Geoloqi sharedInstance] errorProcessingAPIRequest];
			return;
		}
		
		[textView resignFirstResponder];
		
		/*
		GeonoteConfirmationViewController *confirmationViewController = [[[GeonoteConfirmationViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		
		confirmationViewController.geonote = self.geonote;
		
		UINavigationController *wrapper = [[[UINavigationController alloc] initWithRootViewController:confirmationViewController] autorelease];
		
		confirmationViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
																										 style:UIBarButtonItemStyleDone 
																										target:confirmationViewController
																										action:@selector(dismiss:)] autorelease];
		
		[self.navigationController presentModalViewController:wrapper animated:YES];
		*/
		
		[[SHKActivityIndicator currentIndicator] displayCompleted:@"Geonote created!"];
	
		// Restore the Geonote tabe to its original state showing the map
		
		UITabBarController *appTabBarController = ((UITabBarController *)self.parentViewController.parentViewController);
		UINavigationController *geonoteNavigationController = ((UINavigationController *)appTabBarController.selectedViewController);
		
		[geonoteNavigationController popToRootViewControllerAnimated:YES];
		[appTabBarController dismissModalViewControllerAnimated:YES];
		
	} copy];
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
		NSLog(@"Geonote text changed: %@", aTextView.text);
        
        return NO;
    }
    
    return YES;
}

@end