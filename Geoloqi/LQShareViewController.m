//
//  LQShareViewController.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "Geoloqi.h"
#import "CJSONDeserializer.h"
#import "LQShareViewController.h"
#import "SHK.h"




@implementation LQShareViewController

@synthesize durations, durationMinutes;
@synthesize shareDescriptionField, pickerView;
@synthesize activityIndicator;

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
	selectedMinutes = @"30";

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
	[durations addObject:@"4 hours"];
	[durationMinutes addObject:@"240"];
	[durations addObject:@"8 hours"];
	[durationMinutes addObject:@"480"];
	[durations addObject:@"24 hours"];
	[durationMinutes addObject:@"1440"];
	[durations addObject:@"4 days"];
	[durationMinutes addObject:@"5760"];
	[durations addObject:@"7 days"];
	[durationMinutes addObject:@"10080"];
	[durations addObject:@"No time limit"];
	[durationMinutes addObject:@"0"];
	
	[pickerView reloadAllComponents];
	[pickerView selectRow:2 inComponent:0 animated:NO];
	
	[gAppDelegate makeLQButton:shareBtnEmail];
	[gAppDelegate makeLQButton:shareBtnSMS];
	[gAppDelegate makeLQButton:shareBtnTwitter];
	[gAppDelegate makeLQButton:shareBtnFacebook];
	[gAppDelegate makeLQButton:shareBtnCopy];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture.png"]]];
	
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

- (void)viewWillAppear:(BOOL)animated {
	self.activityIndicator.alpha = 0.0f;
}

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

/*
 * Hide the keyboard when the user presses "done". I can't believe this isn't built into the OS...
 */
-(IBAction)textFieldReturn:(id)sender
{
	[sender resignFirstResponder];
}

/*
 * Hide the keyboard when the user taps the background
 */
-(IBAction)backgroundTouched:(id)sender
{
	NSLog(@"Background tapped");
	[[self shareDescriptionField] resignFirstResponder];
}

- (IBAction)tappedShare:(id)sender
{
	self.activityIndicator.alpha = 1.0f;
	
    [[Geoloqi sharedInstance] createLink:[shareDescriptionField text] 
                                 minutes:[selectedMinutes intValue]
                                callback:[self linkCreatedCallback]];
    
}

- (LQHTTPRequestCallback)linkCreatedCallback {
	if (linkCreatedCallback) return linkCreatedCallback;
	NSLog(@"Making a new linkCreatedCallback block");
	return linkCreatedCallback = [^(NSError *error, NSString *responseBody) {
		NSLog(@"Link Created!");

		self.activityIndicator.alpha = 0.0f;
		
		NSError *err = nil;
		NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
																					   NSUTF8StringEncoding]
																				error:&err];
		if (!res || [res objectForKey:@"error"] != nil) {
			NSLog(@"Error deserializing response (for link/create) \"%@\": %@", responseBody, err);
			[[Geoloqi sharedInstance] errorProcessingAPIRequest];
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
		
	} copy];
}

- (IBAction)cancelWasTapped {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
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
	[linkCreatedCallback release];
    [super dealloc];
}


@end
