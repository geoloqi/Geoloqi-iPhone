//
//  GLMappedSlider.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 7/2/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GLMappedSlider : UISlider {
	NSArray *mapping;
	id<NSObject> target;
	SEL action;
}
@property (nonatomic, copy) NSArray *mapping;
@property (nonatomic, assign) id<NSObject> target;
@property (nonatomic) SEL action;

@property (nonatomic) float mappedValue;

@end
