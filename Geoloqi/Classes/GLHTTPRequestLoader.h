//
//  GLHTTPRequestLoader.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GLHTTPRequestCallback)(NSError *error, NSString *responseBody);

@interface GLHTTPRequestLoader : NSObject {
	NSURLConnection *connection;
	NSMutableData *data;
	GLHTTPRequestCallback callback;
}

+ (void)loadRequest:(NSURLRequest *)request
		   callback:(GLHTTPRequestCallback)block;

@end
