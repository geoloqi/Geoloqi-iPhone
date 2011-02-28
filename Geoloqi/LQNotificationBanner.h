//
//  LQNotificationBanner.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-27.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geoloqi.h"


@interface LQNotificationBanner : UIView {
	NSString *img;
	NSString *text;
	NSString *link;
	NSDate *lastUpdated;
	CLLocation *lastLocation;
	LQHTTPRequestCallback callback;
}

@property (nonatomic, retain) NSString *img, *text, *link;
@property (nonatomic, retain) CLLocation *lastLocation;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

- (void)refreshForLocation:(CLLocation *)location;

@end
