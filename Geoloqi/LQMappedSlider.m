//
//  LQMappedSlider.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 7/2/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQMappedSlider.h"


@implementation LQMappedSlider

@synthesize mapping, target, action, finishAction;

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		[self addTarget:self
				 action:@selector(valueChanged:)
	   forControlEvents:UIControlEventValueChanged];
		[self addTarget:self
				 action:@selector(valueChangeDidFinish:)
	   forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

- (void)setMapping:(NSArray *)map {
	[mapping release];
	mapping = [map copy];
	self.maximumValue = [map count]-1; // max value = number of positions
}

- (void)valueChanged:(id)sender {
	self.value = round(self.value); // snap to each position
	[target performSelector:action
				 withObject:self];
}

- (void)valueChangeDidFinish:(id)sender {
	if(!finishAction) {
		return;
	}
	[target performSelector:finishAction
				 withObject:self];
}

- (float)mappedValue {
	return [[mapping objectAtIndex:round(self.value)] floatValue];
}
- (void)setMappedValue:(float)newVal {
	self.value = [self findIndexForValue:newVal];
}

- (NSUInteger)findIndexForValue:(float)val {
	NSUInteger values = [mapping count];
	if (values <= 0) return 0;
	
	// Find value in mapping dict with least difference from target
	float bestDiff;
	NSUInteger bestValIndex;
	
	for (NSUInteger i = 0; i < values; i++) {
		float curVal = [[mapping objectAtIndex:i] floatValue];
		float diff = abs(curVal - val);
		if (i == 0 || diff < bestDiff) {
			bestDiff = diff;
			bestValIndex = i;
		}
	}
	
	return bestValIndex;
}

- (void)setMappedValue:(float)newVal animated:(BOOL)animated {
	[self setValue:[self findIndexForValue:newVal] animated:animated];
}

- (void)dealloc {
	[mapping release];
    [super dealloc];
}


@end
