//
//  PKHTTPCachedImage.h
//  Geoloqi
//
//  Created by Aaron Parecki on 12/19/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

@interface PKHTTPCachedImage : NSObject {

}

+ (PKHTTPCachedImage *)sharedInstance;

- (void)setImageForView:(UIImageView *)view withURL:(NSString *)url;

@property (nonatomic, retain) NSMutableDictionary *cachedImages;

@end
