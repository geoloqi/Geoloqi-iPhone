//
//  LQMapPinAnnotation.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-03-04.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LQMapPinAnnotation : NSObject <MKAnnotation> {

}

@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
