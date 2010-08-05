//
//  LocationUpdateRequest.h
//  LocationUpdater
//
//  Created by Andrew Pouliot on 5/30/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"

#import <CoreLocation/CoreLocation.h>

@interface LocationUpdateRequest : ASIHTTPRequest {
}

- (void)setLocationDataFromLocations:(NSArray *)locations;
- (NSString *)hardware;

@end
