//
//  LQNotificationBanner.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geoloqi.h"


@interface LQNotificationBanner : NSObject {
	NSString *img;
	NSString *text;
	NSString *link;
	NSDate *lastUpdated;
	LQHTTPRequestCallback callback;
	LQHTTPRequestCallback loadedCallback;
}

@property (nonatomic, retain) NSString *img, *text, *link;

- (void)refreshWithCallback:(LQHTTPRequestCallback)cb;

@end
