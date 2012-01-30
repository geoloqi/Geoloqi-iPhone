//
//  LQDataViewController.m
//  Geoloqi
//
//  Created by caseorganic on 6/3/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQDataViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LQMappedSlider.h"
#import "Geoloqi.h"
#import "LQAboutViewController.h"

NSString *const LQTrackingOnUserInfoKey = @"LQTrackingOnUserInfoKey";

enum {
	kSectionCoords = 0,
	kSectionBasic,
//	kSectionTrackingMode,
	kSectionAdvanced,
	kSectionFooter,
	kNumberOfSections
};

enum {
	kTrackingModeBatterySaver = 0,
	kTrackingModeHiRes,
	kTrackingModeCustom
};

@interface LQDataViewController () // Private methods
- (void)updateLabels;
- (void)updatePreset;
- (NSString *)formatSeconds:(NSTimeInterval)s;
- (void)distanceFilterWasChanged:(LQMappedSlider *)sender;
- (void)trackingFrequencyWasChanged:(LQMappedSlider *)sender;
- (void)sendingFrequencyWasChanged:(LQMappedSlider *)sender;
@end


@implementation LQDataViewController

@synthesize table;
@synthesize updateQueueCell;
@synthesize checkInCell, checkInButton;
@synthesize coordsCell, latLabel, longLabel, altLabel, spdLabel;
@synthesize trackingModeCell, trackingModeSwitch;
@synthesize trackingToggleCell, trackingToggleSwitch; // __dbhan: Gotcha
@synthesize distanceFilterCell, distanceFilterLabel, distanceFilterSlider;
@synthesize trackingFrequencyCell, trackingFrequencyLabel, trackingFrequencySlider;
@synthesize sendingFrequencyCell, sendingFrequencyLabel, sendingFrequencySlider;
@synthesize logoutCell, logoutButton, usernameLabel;
@synthesize aboutButton;
@synthesize trackingMode;
//@synthesize realTimeTrackingCell, realTimeTrackingSwitch, realTimeTrackingLabel; //__dbhan: synthesize the three newly added fields to determine send method

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.table setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture.png"]]];
	
	// Load from defaultsLQMapped
	trackingToggleSwitch.on = ![[Geoloqi sharedInstance] locationUpdatesState]; //_dbhan: Gotcha!
	trackingMode = [[Geoloqi sharedInstance] getTrackingMode];
    trackingModeSwitch.selectedSegmentIndex = trackingMode; //__dbhan: ok to set it?????
	[self updatePreset];

#if (VERBOSE)    
    NSLog(@"The tracking mode is: %d", trackingModeSwitch.selectedSegmentIndex); // __dbhan
#endif
	
    // hide the spinner at first
	sendingActivityIndicator.hidden = YES;
	[self updateButtonStates];
	NSDictionary *sliderMappings = [NSDictionary dictionaryWithContentsOfFile:
									[[NSBundle mainBundle] pathForResource:@"SliderMappings"
																	ofType:@"plist"]];
    sendingFrequencySlider.mapping = [sliderMappings objectForKey:@"rate_limit"];
	sendingFrequencySlider.target = self;
	sendingFrequencySlider.action = @selector(changeSendingFrequency:);
	sendingFrequencySlider.finishAction = @selector(sendingFrequencyWasChanged:);
    sendingFrequencySlider.mappedValue = [[Geoloqi sharedInstance] sendingFrequency];
#if(VERBOSE)
    NSLog(@"The sending Frequency is set to : %@", [[Geoloqi sharedInstance] sendingFrequency]);
#endif

    // Set up cells
	trackingToggleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												reuseIdentifier:nil];
	trackingToggleCell.textLabel.text = @"Disable Location";
	trackingToggleCell.accessoryView = trackingToggleSwitch;
	trackingToggleCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    checkInCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:nil];
	checkInCell.textLabel.text = @"Check In Once";
	checkInCell.accessoryView = checkInButton;
	checkInCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	[gAppDelegate makeLQButtonLight:checkInButton];
	[gAppDelegate makeLQButtonLight:sendNowButton];
	[gAppDelegate makeLQButtonLight:logoutButton];
	
	UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
	v.backgroundColor = [UIColor clearColor];
	coordsCell.backgroundView = v;
	[v release];
	
	// Set up long-tap-to-copy
	UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc]
										initWithTarget:self
										action:@selector(coordLongPressDetected)];
	[coordsCell addGestureRecognizer:gr];
	[gr release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationUpdated:)
												 name:LQLocationUpdateManagerDidUpdateLocationNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationUpdated:)
												 name:LQLocationUpdateManagerFinishedSendingSingleLocation
											   object:nil];

}

- (void)startViewRefreshTimer {
	viewRefreshTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(viewRefreshTimerDidFire:)
                                                       userInfo:nil
                                                        repeats:YES] retain];    
}

- (void)stopViewRefreshTimer {
	[viewRefreshTimer invalidate];
	[viewRefreshTimer release];
	viewRefreshTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    trackingMode = [[Geoloqi sharedInstance] getTrackingMode];

    [self updateTrackingModeAndToggleStates:animated];
    
    sendingFrequencySlider.mappedValue = [[Geoloqi sharedInstance] sendingFrequency];
    NSLog(@"The sending frequency is:%f", [[Geoloqi sharedInstance] sendingFrequency]);
    
    [self updatePreset];
    
	self.usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(startedSendingLocations:)
												 name:LQLocationUpdateManagerStartedSendingLocations
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(finishedSendingLocations:)
												 name:LQLocationUpdateManagerFinishedSendingLocations
											   object:nil];
    [self startViewRefreshTimer];

	[self viewRefreshTimerDidFire:nil];
    [table reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQLocationUpdateManagerStartedSendingLocations
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQLocationUpdateManagerFinishedSendingLocations
                                                  object:nil];
	
	[viewRefreshTimer invalidate];
	[viewRefreshTimer release];
	viewRefreshTimer = nil;
}

// This method is called when Geoloqi starts sending location updates to the server
- (void)startedSendingLocations:(NSNotification *)notification {
	NSLog(@"startedSendingLocations");
	sendingActivityIndicator.hidden = NO;
	[self updateButtonStates];
}
// This method is called when the location sending method completes
- (void)finishedSendingLocations:(NSNotification *)notification {
	NSLog(@"finishedSendingLocations");
	sendingActivityIndicator.hidden = YES;
	if(![[Geoloqi sharedInstance] locationUpdatesState]) {
		[self updateButtonStates];
	}
}

- (void)updateTrackingModeAndToggleStates:(BOOL)animated {
    [trackingToggleSwitch setOn:![[Geoloqi sharedInstance] locationUpdatesState] animated:animated];
    if([[Geoloqi sharedInstance] locationUpdatesState] == FALSE) {
        trackingModeSwitch.selectedSegmentIndex = UISegmentedControlNoSegment;
    } else {
        trackingMode = [[Geoloqi sharedInstance] getTrackingMode];
        trackingModeSwitch.selectedSegmentIndex = trackingMode; //__dbhan: ok to set it?????
    }
}

- (void)viewRefreshTimerDidFire:(NSTimer *)timer {
	// Update the "Last point:" status text
	// [trackingToggleSwitch setOn:![[Geoloqi sharedInstance] locationUpdatesState] animated:YES];   // __dbhan: Gotcha
//    if([[Geoloqi sharedInstance] locationUpdatesState] == FALSE) {
//        trackingModeSwitch.selectedSegmentIndex = UISegmentedControlNoSegment;
//    } else {
//        trackingMode = [[Geoloqi sharedInstance] getTrackingMode];
//        trackingModeSwitch.selectedSegmentIndex = trackingMode; //__dbhan: ok to set it?????
//    }
    //[self.table reloadData];                 //__dbhan : Reload the table again, as we need to draw the rate limit slider.
	[self updateButtonStates];
	[self updateLabels];
}

- (void)locationUpdated:(NSNotification *)theNotification {
	[self updateButtonStates];
	[self updateLabels];
	//[self.table reloadSections:[NSIndexSet indexSetWithIndex:kSectionCoords]
	//		  withRowAnimation:UITableViewRowAnimationNone];
}

- (void)coordLongPressDetected {
	if (![[Geoloqi sharedInstance] currentLocation]) return;
	
	// Highlight the appropriate labels
	NSArray *subviews = coordsCell.contentView.subviews;
	for (UIView *v in subviews) {
		if ([v isKindOfClass:[UILabel class]]) {
			((UILabel *)v).highlighted = YES;
		}
	}
	[self becomeFirstResponder];
	UIMenuController *mc = [UIMenuController sharedMenuController];
	
	// Determine rect around coordinate labels to display the menu
	CGRect latFrame = latLabel.frame;
	latFrame.size = [latLabel sizeThatFits:CGSizeZero];
	CGRect longFrame = longLabel.frame;
	longFrame.size = [longLabel sizeThatFits:CGSizeZero];
	
	[mc setTargetRect:CGRectUnion(latFrame, longFrame)
			   inView:coordsCell.contentView];
	mc.arrowDirection = UIMenuControllerArrowLeft;
	
	// Show the menu!
	[mc setMenuVisible:YES animated:YES];
	
	// Un-highlight the labels when the menu is dismissed
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(menuWillHide:)
												 name:UIMenuControllerWillHideMenuNotification
											   object:nil];
}
- (void)menuWillHide:(NSNotification *)theNotification {
	NSArray *subviews = coordsCell.contentView.subviews;
	for (UIView *v in subviews) {
		if ([v isKindOfClass:[UILabel class]]) {
			((UILabel *)v).highlighted = NO;
		}
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIMenuControllerWillHideMenuNotification
												  object:nil];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(copy:)) {
		return YES;
	}
	return NO;
}
- (BOOL)canBecomeFirstResponder {
	return YES;
}
- (void)copy:(id)sender {
	// Copy "lat, long" to the clipboard
	CLLocationCoordinate2D coord = [[Geoloqi sharedInstance] currentLocation].coordinate;
	[UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%f, %f",
											   coord.latitude, coord.longitude];
}

#pragma mark -
#pragma mark Sliders

- (void)toggleTracking:(UISwitch *)sender {
    NSLog(@"[Settings] toggleTracking:%@", (sender.on?@"on":@"off"));
    [self stopViewRefreshTimer];
	if(!sender.on){
		[[Geoloqi sharedInstance] startLocationUpdates];
	}else{
		[[Geoloqi sharedInstance] stopLocationUpdates];
	}
    [self viewRefreshTimerDidFire:nil];
    [self startViewRefreshTimer];
    [self updateTrackingModeAndToggleStates:YES];
}

- (IBAction)trackingModeWasChanged:(UISegmentedControl *)control {
    [self stopViewRefreshTimer];
	// Load the default slider values from the user preferences
	if (control.selectedSegmentIndex == kTrackingModeBatterySaver) 
    {
		NSLog(@"Setting to battery saver mode");
        self.trackingMode = LQBatterySaverMode;
        //__dbhan: Last but not the least
        [[Geoloqi sharedInstance] setTrackingModeTo:LQBatterySaverMode];
        [[Geoloqi sharedInstance] setTrackingPreset:LQBatterySaverMode];
	} 
    else if (control.selectedSegmentIndex == kTrackingModeHiRes)
    {
		NSLog(@"Setting to high res mode");
        self.trackingMode = LQHiResMode;
        [[Geoloqi sharedInstance] setTrackingModeTo:LQHiResMode]; // __dbhan:
        [[Geoloqi sharedInstance] setTrackingPreset:LQHiResMode];
	} 
    else if (control.selectedSegmentIndex == kTrackingModeCustom)
    {
		NSLog(@"Setting to custom mode");
        self.trackingMode = LQCustomMode;
        [[Geoloqi sharedInstance] setTrackingModeTo:LQCustomMode]; // __dbhan:
        [[Geoloqi sharedInstance] setTrackingPreset:LQCustomMode];
        [sendingFrequencySlider setMappedValue:[[Geoloqi sharedInstance] sendingFrequency] animated:YES];  // __dbhan: set frequency slider and animate it..
	}
    [self.table reloadData];                                      //__dbhan : Reload the table again, as we need to draw the rate limit slider.
    [self viewRefreshTimerDidFire:nil];
    [self startViewRefreshTimer];
    [self updateTrackingModeAndToggleStates:YES];
}

- (void)saveCustomSliderPresets {
	// Save the values of the sliders into the "custom" preset
	//[[NSUserDefaults standardUserDefaults] setDouble:self.distanceFilterSlider.mappedValue forKey:@"customDistanceFilter"];
	//[[NSUserDefaults standardUserDefaults] setDouble:self.trackingFrequencySlider.mappedValue forKey:@"customTrackingLimit"];
	[[NSUserDefaults standardUserDefaults] setDouble:self.sendingFrequencySlider.mappedValue forKey:@"customRateLimit"];
	NSLog(@"%f", self.sendingFrequencySlider.mappedValue);
	NSLog(@"Updating custom slider presets");
}

// __dbhan: These functions are no longer needed
- (void)changeDistanceFilter:(LQMappedSlider *)sender {
	[self updateLabels];
}
- (void)distanceFilterWasChanged:(LQMappedSlider *)sender {
	//TODO: use kCLDistanceFilterNone?
	[[Geoloqi sharedInstance] setDistanceFilterTo:sender.mappedValue];
	[self saveCustomSliderPresets];
	[self updatePreset];
	[self updateLabels];
}
- (void)changeTrackingFrequency:(LQMappedSlider *)sender {
	[self updateLabels];
}
- (void)trackingFrequencyWasChanged:(LQMappedSlider *)sender {
	[[Geoloqi sharedInstance] setTrackingFrequencyTo:sender.mappedValue];
	[self saveCustomSliderPresets];
	[self updatePreset];
	[self updateLabels];
}

//__dbhan: Till here

- (void)changeSendingFrequency:(LQMappedSlider *)sender {
	[self updateLabels];
}
- (void)sendingFrequencyWasChanged:(LQMappedSlider *)sender {
	[[Geoloqi sharedInstance] setSendingFrequencyTo:sender.mappedValue];
    [[NSUserDefaults standardUserDefaults] setDouble:sender.mappedValue forKey:@"customRateLimit"];
	[self saveCustomSliderPresets];
	[self updatePreset];
	[self updateLabels];
}

//__dbhan: Updated this function for new logic
- (void)updatePreset 
{
    if (trackingMode == LQBatterySaverMode)
    {
		trackingModeSwitch.selectedSegmentIndex = kTrackingModeBatterySaver;
	}
    else if (trackingMode == LQHiResMode)
    {
		trackingModeSwitch.selectedSegmentIndex = kTrackingModeHiRes;
	} 
    else 
    {
        trackingModeSwitch.selectedSegmentIndex = kTrackingModeCustom;
	}
}

- (void)updateLabels {
	CLLocationCoordinate2D coord;
	CLLocation *loc;
	BOOL hasLocation = NO;
	
	if ([[Geoloqi sharedInstance] locationUpdatesState]) {
		if([[Geoloqi sharedInstance] currentLocation]) {
			loc = [[Geoloqi sharedInstance] currentLocation];
			coord = [[Geoloqi sharedInstance] currentLocation].coordinate;
			hasLocation = YES;
		}
	} else {
		if([[Geoloqi sharedInstance] currentSingleLocation]) {
			loc = [[Geoloqi sharedInstance] currentSingleLocation];
			coord = [[Geoloqi sharedInstance] currentSingleLocation].coordinate;
			hasLocation = YES;
		}
	}
	if (hasLocation) {
		latLabel.text = [NSString stringWithFormat:@"%f", coord.latitude];
		longLabel.text = [NSString stringWithFormat:@"%f", coord.longitude];
		if(loc.speed < 0) {
			spdLabel.text = @"--";
		} else {
			spdLabel.text = [NSString stringWithFormat:@"%.0f km/h", (loc.speed * 3.6)];
		}
		altLabel.text = [NSString stringWithFormat:@"%.0f m", loc.altitude];
	} else {
		latLabel.text = longLabel.text = altLabel.text = spdLabel.text = @"";
	}
	
	distanceFilterLabel.text = [NSString stringWithFormat:@"%.0fm",
								distanceFilterSlider.mappedValue];
	trackingFrequencyLabel.text = [self formatSeconds:trackingFrequencySlider.mappedValue];
	sendingFrequencyLabel.text = [self formatSeconds:sendingFrequencySlider.mappedValue];
	
	NSTimeInterval ago = [[NSDate date] timeIntervalSinceDate:[[Geoloqi sharedInstance] lastUpdateDate]];
	
	if ([[Geoloqi sharedInstance] lastUpdateDate] == nil) {
		lastUpdateLabel.text = @"Not sent yet";
	} else if ([[Geoloqi sharedInstance] lastUpdateDate] && ago > 60) {
		lastUpdateLabel.text = [NSString stringWithFormat:@"%.0fm %.0fs ago", floor(ago/60), fmod(ago, 60)];
	} else {
		lastUpdateLabel.text = [NSString stringWithFormat:@"%.0fs ago", ago];
	}
	NSUInteger pts = [[Geoloqi sharedInstance] getLocationQueueCount]; //__dbhan: location points queue
	inQueueLabel.text = [NSString stringWithFormat:@"%d point%@", pts, (pts == 1) ? @"" : @"s"];
}

- (NSString *)formatSeconds:(NSTimeInterval)s {
	if (s < 60) {
		return [NSString stringWithFormat:@"%.0fs", s];
	} else {
		return [NSString stringWithFormat:@"%.0fm", s/60.0];
	}
}

#pragma mark -
#pragma mark Table view delegate/datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kNumberOfSections;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case kSectionBasic:
            if(trackingMode == LQCustomMode)
                return 2;
            else
                return 1;
		case kSectionCoords:
		//case kSectionTrackingMode:
			return 1;
		case kSectionAdvanced:
            return 2;
		case kSectionFooter:
			return 1;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section) {
		case kSectionBasic:
			switch (indexPath.row) {
                case 0: return trackingModeCell;
                case 1:
                    if(trackingMode == LQCustomMode)
                        return sendingFrequencyCell;
                    else 
                        return nil;
				default: return nil;
			}
		case kSectionCoords:
			return coordsCell;
		case kSectionAdvanced:
			switch (indexPath.row) {
				case 0: return updateQueueCell;
				case 1: return trackingToggleCell;
				// case 1: return checkInCell;
				default: return nil;
			}
		case kSectionFooter:
			return logoutCell;
		default:
			return nil;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case kSectionBasic:
			switch (indexPath.row) {
				case 0:
					return 56;
				default:
					return 64;
			}
		case kSectionCoords:
			return 40;
		//case kSectionTrackingMode:
		//	return 29;
		case kSectionAdvanced:
			switch (indexPath.row) {
				case 0:
					return 52;
				default:
					return 48;
			}
		case kSectionFooter:
			return 52;
		default:
			return 44;
	}
	return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case kSectionBasic:
			return @"Tracking Mode";
		case kSectionCoords:
		//case kSectionTrackingMode:
			return nil;
		case kSectionAdvanced:
			return nil;
		default:
			return nil;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return nil;
	switch (section) {
		case kSectionBasic:
		case kSectionCoords:
		//case kSectionTrackingMode:
		case kSectionAdvanced:
		default:
			return nil;
	}
}

/********************************************************************************
 * Customize the table group label colors. There is no way to do this with
 * the built in label, so you have to make a separate view for the header
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section] != nil) {
        return 36;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
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

// __dbhan: Checked all the functions till here ... no need to check below this line
/********************************************************************************/

#pragma mark -

- (IBAction)logoutButtonWasTapped:(UIButton *)button {
	// For testing the battery notifications in the simulator
	// [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceBatteryLevelDidChangeNotification object:self];
	
	// Set a notification with a fraction of a second delay so they know the app didn't just crash
	
	UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
	// TODO: This is from Apple's sample code. When would this not be set?
	if (notification == nil)
		return;
	
	notification.alertBody = @"You successfully logged out. Would you like to launch Geoloqi again?";
	notification.alertAction = @"Yes";
	notification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.3];
	
	// Schedule the notification
	[[UIApplication sharedApplication] scheduleLocalNotification:notification];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:LQAuthenticationLogoutNotification object:self];
}

- (IBAction)sendNowWasTapped:(UIButton *)button {
	NSLog(@"Send now was tapped");
	if([[Geoloqi sharedInstance] locationUpdatesState]) {
		// If passive location updates are on, flush the queue of points
		[[Geoloqi sharedInstance] sendQueuedPoints];
	}
}

- (IBAction)checkInButtonWasTapped:(UIButton *)button {
	NSLog(@"Checkin button was tapped");
	
	// If passive location updates are off, get the user's location and send a single point
	[[Geoloqi sharedInstance] singleLocationUpdate];
}

- (IBAction)aboutButtonWasTapped:(UIButton *)button {
	LQAboutViewController *aboutView = [[LQAboutViewController alloc] init];
	[self presentModalViewController:aboutView animated:YES];
	[aboutView release];
}

- (void)updateButtonStates {
    return;
	if([[Geoloqi sharedInstance] locationUpdatesState]) {
		// Background location is on. Don't allow checkin, allow flushing the queue if there are points.

		if ([[Geoloqi sharedInstance] getLocationQueueCount] > 0) {
			sendNowButton.enabled = YES;
			//[sendNowButton setTitleColor:[UIColor colorWithRed:0.215 green:0.32 blue:0.508 alpha:1.0] forState:UIControlStateNormal];
		} else {
			sendNowButton.enabled = NO;
			//[sendNowButton setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0] forState:UIControlStateNormal];
		}
		
		checkInButton.enabled = NO;
		//[checkInButton setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0] forState:UIControlStateNormal];
		
	} else {
		// Background location is off. Allow checkin, don't allow flushing the queue.
		
		sendNowButton.enabled = NO;
		//[sendNowButton setTitleColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0] forState:UIControlStateNormal];

		checkInButton.enabled = YES;
		//[checkInButton setTitleColor:[UIColor colorWithRed:0.215 green:0.32 blue:0.508 alpha:1.0] forState:UIControlStateNormal];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[viewRefreshTimer invalidate];
	[viewRefreshTimer release];
	[coordsCell release];
	[trackingToggleCell release];
	[trackingFrequencyCell release];
	[latLabel release];
	[longLabel release];
	[altLabel release];
	[spdLabel release];
	[trackingFrequencyLabel release];
	[trackingToggleSwitch release]; // __dbhan: Gotcha
    [super dealloc];
}


@end
