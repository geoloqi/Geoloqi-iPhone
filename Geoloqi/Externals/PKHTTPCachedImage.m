//
//  PKHTTPCachedImage.m
//  Geoloqi
//
//  Created by Aaron Parecki on 12/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "PKHTTPCachedImage.h"

static PKHTTPCachedImage *sharedInstance = nil;

@implementation PKHTTPCachedImage

@synthesize cachedImages;

+ (PKHTTPCachedImage *)sharedInstance {
    if (!sharedInstance) {
		sharedInstance = [[self alloc] init];
		sharedInstance.cachedImages = [[NSMutableDictionary alloc] init];
	}
    
	return sharedInstance;
}

- (void)setImageForView:(UIImageView *)view withURL:(NSString *)url {
	UIImage *img;
	if((img = [self.cachedImages objectForKey:url]) != nil) {
		view.image = img;
		return;
	}
	
	dispatch_async(dispatch_get_global_queue(0,0), ^{
		UIImage *img = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: url]]];
		[self.cachedImages setValue:img forKey:url];
		dispatch_async(dispatch_get_main_queue(), ^{
			view.image = img;
		});
	});
}


- (void)dealloc {
	[self.cachedImages release];
    [super dealloc];
}


@end
