//
//  GLDataViewController.m
//  Geoloqi
//
//  Created by caseorganic on 6/3/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GLDataViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GLMappedSlider.h"

NSString *const GLTrackingOnUserInfoKey = @"GLTrackingOnUserInfoKey";

enum {
	kSectionCoordinates = 0,
	kSectionTrackingToggle,
	kSectionSliders,
//	kSectionDistanceFilter,
//	kSectionTrackingFrequency,
//	kSectionSendingFrequency,
	kNumberOfSections
};

@interface GLDataViewController () // Private methods
- (void)updateLabels;
- (NSString *)formatSeconds:(NSTimeInterval)s;
@end


@implementation GLDataViewController

@synthesize coordsCell, latLabel, longLabel;
@synthesize trackingToggleCell, trackingToggleSwitch;
@synthesize distanceFilterCell, distanceFilterLabel, distanceFilterSlider;
@synthesize trackingFrequencyCell, trackingFrequencyLabel, trackingFrequencySlider;
@synthesize sendingFrequencyCell, sendingFrequencyLabel, sendingFrequencySlider;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Load from defaults
	trackingToggleSwitch.on = [[Geoloqi sharedInstance] locationUpdatesState];
	//trackingFrequencySlider.enabled = sender.on;
	
	NSDictionary *sliderMappings = [NSDictionary dictionaryWithContentsOfFile:
									[[NSBundle mainBundle] pathForResource:@"SliderMappings"
																	ofType:@"plist"]];
	
	distanceFilterSlider.mapping = [sliderMappings objectForKey:@"distance_filter"];
	distanceFilterSlider.target = self;
	distanceFilterSlider.action = @selector(changeDistanceFilter:);
	distanceFilterSlider.mappedValue = [[Geoloqi sharedInstance] distanceFilterDistance];
	
	trackingFrequencySlider.mapping = [sliderMappings objectForKey:@"tracking_limit"];
	trackingFrequencySlider.target = self;
	trackingFrequencySlider.action = @selector(changeTrackingFrequency:);
	trackingFrequencySlider.mappedValue = [[Geoloqi sharedInstance] trackingFrequency];
	
	sendingFrequencySlider.mapping = [sliderMappings objectForKey:@"rate_limit"];
	sendingFrequencySlider.target = self;
	sendingFrequencySlider.action = @selector(changeSendingFrequency:);
	sendingFrequencySlider.mappedValue = [[Geoloqi sharedInstance] sendingFrequency];
	
	[self updateLabels];
	
	// Set up cells
	trackingToggleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												reuseIdentifier:nil];
	trackingToggleCell.textLabel.text = @"Location Tracking";
	trackingToggleCell.accessoryView = trackingToggleSwitch;
	trackingToggleCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
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
												 name:GLLocationUpdateManagerDidUpdateLocationNotification
											   object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// Update the "Last point:" status text
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionTrackingToggle]
				  withRowAnimation:UITableViewRowAnimationNone];
}
- (void)locationUpdated:(NSNotification *)theNotification {
	[self updateLabels];
//	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kSectionTrackingToggle]
//				  withRowAnimation:UITableViewRowAnimationNone];
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
	[[Geoloqi sharedInstance] setLocationUpdatesTo:sender.on];
	//trackingFrequencySlider.enabled = sender.on;
}
- (void)changeDistanceFilter:(GLMappedSlider *)sender {
	//TODO: use kCLDistanceFilterNone?
	[[Geoloqi sharedInstance] setDistanceFilterTo:sender.mappedValue];
	[self updateLabels];
}
- (void)changeTrackingFrequency:(GLMappedSlider *)sender {
	[[Geoloqi sharedInstance] setTrackingFrequencyTo:sender.mappedValue];
	[self updateLabels];
}
- (void)changeSendingFrequency:(GLMappedSlider *)sender {
	[[Geoloqi sharedInstance] setSendingFrequencyTo:sender.mappedValue];
	[self updateLabels];
}
- (void)updateLabels {
	if ([[Geoloqi sharedInstance] currentLocation]) {
		CLLocationCoordinate2D coord = [[Geoloqi sharedInstance] currentLocation].coordinate;
		latLabel.text = [NSString stringWithFormat:@"%f", coord.latitude];
		longLabel.text = [NSString stringWithFormat:@"%f", coord.longitude];
	} else {
		latLabel.text = longLabel.text = @"-";
	}
	
	distanceFilterLabel.text = [NSString stringWithFormat:@"%.0fm",
								distanceFilterSlider.mappedValue];
	trackingFrequencyLabel.text = [self formatSeconds:trackingFrequencySlider.mappedValue];
	sendingFrequencyLabel.text = [self formatSeconds:sendingFrequencySlider.mappedValue];
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
		case kSectionCoordinates:
		case kSectionTrackingToggle:
			return 1;
		case kSectionSliders:
			return 3;
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	switch (indexPath.section) {
		case kSectionCoordinates:
			return coordsCell;
		case kSectionTrackingToggle:
			return trackingToggleCell;
		case kSectionSliders:
			switch (indexPath.row) {
				case 0: return distanceFilterCell;
				case 1: return trackingFrequencyCell;
				case 2: return sendingFrequencyCell;
				default: return nil;
			}
		default:
			return nil;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case kSectionCoordinates:
		case kSectionTrackingToggle:
			return 44;
		case kSectionSliders:
			return 64;
		default:
			return 44;
	}
	return 44;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case kSectionCoordinates:
			return nil;
		case kSectionTrackingToggle:
		{
			NSMutableString *footer = [NSMutableString string];
			
			NSTimeInterval ago = [[NSDate date] timeIntervalSinceDate:
								  [[Geoloqi sharedInstance] currentLocation].timestamp];
			if (ago > 60) {
				[footer appendFormat:
						@"Last update: %.0f min. %.0f sec. ago",
						floor(ago/60), fmod(ago, 60)];
			} else {
				[footer appendFormat:@"Last update: %.0f second%@ ago", ago, (ago == 1.0) ? @"" : @"s"];
			}
			
			NSUInteger pts = [[Geoloqi sharedInstance] locationQueueCount];
			[footer appendFormat:@"\nQueue: %d unsent point%@", pts, (pts == 1) ? @"" : @"s"];
			
			return footer;
		}
//		case kSectionDistanceFilter:
//			return @"Minimum position change";
//		case kSectionTrackingFrequency:
//			return @"Minimum time between points";
//		case kSectionSendingFrequency:
//			return @"Minimum time between server calls";
		default:
			return nil;
	}
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	switch (section) {
//		case kSectionCoordinates:
//		case kSectionTrackingToggle:
//			return nil;
//		case kSectionDistanceFilter:
//			return @"Distance Filter";
//		case kSectionTrackingFrequency:
//			return @"Tracking Frequency";
//		case kSectionSendingFrequency:
//			return @"Sending Frequency";
//		default:
//			return nil;
//	}
//	return nil;
//}

//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//	if (section == [cells count] - 1) {
//		return trackingFrequencyLabel.bounds.size.height;
//	}
//	return 0;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//	if (section == [cells count] - 1) {
//		return trackingFrequencyLabel;
//	}
//	return nil;
//}

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
	[coordsCell release];
	[trackingToggleCell release];
	[trackingFrequencyCell release];
	[latLabel release];
	[longLabel release];
	[trackingFrequencyLabel release];
	[trackingToggleSwitch release];
    [super dealloc];
}


@end
