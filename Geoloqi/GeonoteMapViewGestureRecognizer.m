//
//  GeonoteMapViewGestureRecognizer.m
//  Geoloqi
//
//  Created by Aaron Parecki on 12/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GeonoteMapViewGestureRecognizer.h"


@implementation GeonoteMapViewGestureRecognizer

@synthesize touchesBeganCallback;

-(id) init{
	if (self = [super init])
	{
		self.cancelsTouchesInView = NO;
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (touchesBeganCallback)
		touchesBeganCallback(touches, event);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)reset
{
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	return NO;
}

@end
