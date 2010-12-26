//
//  GeonoteMapViewGestureRecognizer.h
//  Geoloqi
//
//  Based on a solution found here:
//  http://stackoverflow.com/questions/1121889/intercepting-hijacking-iphone-touch-events-for-mkmapview/1298330
//
//  Created by Aaron Parecki on 12/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface GeonoteMapViewGestureRecognizer : UIGestureRecognizer {
	TouchesEventBlock touchesBeganCallback;
}

@property(copy) TouchesEventBlock touchesBeganCallback;

@end
