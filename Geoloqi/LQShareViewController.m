//
//  LQShareViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GLAuthenticationManager.h"
#import "LQShareViewController.h"
#import "SHK.h"

#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"



@implementation LQShareViewController

@synthesize durations, durationMinutes;

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	durations = [[NSMutableArray alloc] init];
	durationMinutes = [[NSMutableArray alloc] init];

	[durations addObject:@"10 minutes"];
	[durationMinutes addObject:@"10"];
	[durations addObject:@"20 minutes"];
	[durationMinutes addObject:@"20"];
	[durations addObject:@"30 minutes"];
	[durationMinutes addObject:@"30"];
	[durations addObject:@"40 minutes"];
	[durationMinutes addObject:@"40"];
	[durations addObject:@"50 minutes"];
	[durationMinutes addObject:@"50"];
	[durations addObject:@"1 hour"];
	[durationMinutes addObject:@"60"];
	[durations addObject:@"2 hours"];
	[durationMinutes addObject:@"120"];
	[durations addObject:@"8 hours"];
	[durationMinutes addObject:@"480"];
	[durations addObject:@"24 hours"];
	[durationMinutes addObject:@"1440"];
	[durations addObject:@"7 days"];
	[durationMinutes addObject:@"10080"];
	[durations addObject:@"never"];
	[durationMinutes addObject:@"0"];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*
- (void)share
{
	SHKItem *item = [SHKItem URL:webView.request.URL title:[webView pageTitle]];
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	[actionSheet showFromToolbar:self.navigationController.toolbar]; 
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [durations count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView 
			titleForRow:(NSInteger)row 
		   forComponent:(NSInteger)component {
	return [durations objectAtIndex:row];
}

- (IBAction)tappedShare:(id)sender
{
	/*
	 * TODO: This should use the GLAuthenticationManager, not be handled in this class
	[[GLAuthenticationManager sharedManager] createSharedLinkWithExpirationInMinutes:selectedMinutes
																		withDelegate:self];
	 */
	[self createSharedLinkWithExpirationInMinutes:selectedMinutes];
}

- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes {
	//NSURL *url = [NSURL URLWithString:@"https://api.geoloqi.com/1/link/create"];
	NSURL *url = [NSURL URLWithString:@"http://cpwebtool.org/test.php"];
	
	NSLog(@"About to make the link/create HTTP request!");
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	[request setPostValue:minutes forKey:@"minutes"];
	[request setPostValue:[[GLAuthenticationManager sharedManager] accessToken] forKey:@"oauth_token"];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSString *responseString = [request responseString];

	NSError *err = nil;
	NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseString dataUsingEncoding:
																				   NSUTF8StringEncoding]
																			error:&err];
	if (!res) {
		NSLog(@"Error deserializing response (for link/create) \"%@\": %@", responseString, err);
		return;
	}

	if ([[res objectForKey:@"shortlink"] isKindOfClass:[NSString class]] && [[res objectForKey:@"shortlink"] length])
	{
		NSLog(@"Shared link created %@", [res objectForKey:@"shortlink"]);

		// Create the item to share (in this example, a url)
		NSURL *url = [NSURL URLWithString:[res objectForKey:@"shortlink"]];
		SHKItem *item = [SHKItem URL:url title:@"Heading out! Track me on Geoloqi!"];
		
		// Get the ShareKit action sheet
		SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
		
		// Display the action sheet
		[actionSheet showFromTabBar:gAppDelegate.tabBarController.tabBar];
		
		return;
	}
}


- (void)pickerView:(UIPickerView *)pickerView 
	  didSelectRow:(NSInteger)row 
	   inComponent:(NSInteger)component {
	
	selectedMinutes = [durationMinutes objectAtIndex:row];
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
	[durations release];
	[durationMinutes release];
	[selectedMinutes release];
    [super dealloc];
}


@end
