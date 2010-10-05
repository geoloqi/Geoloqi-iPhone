//
//  GLHTTPRequestLoader.m
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Harvey Mudd College. All rights reserved.
//

#import "GLHTTPRequestLoader.h"

@interface GLHTTPRequestLoader ()
- (void)loadRequest:(NSURLRequest *)request
		   callback:(GLHTTPRequestCallback)block;
@end


@implementation GLHTTPRequestLoader

+ (void)loadRequest:(NSURLRequest *)request
		   callback:(GLHTTPRequestCallback)block {
	GLHTTPRequestLoader *loader = [[self alloc] init];
	[loader loadRequest:request
			   callback:^(NSError *error, NSString *responseBody) {
				   block(error, responseBody);
				   [loader release];
			   }];
}

- (void)loadRequest:(NSURLRequest *)request
		   callback:(GLHTTPRequestCallback)block {
	connection = [[NSURLConnection alloc] initWithRequest:request
												 delegate:self];
	callback = [block copy];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	[data release];
	data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)newData {
	[data appendData:newData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	callback(nil, [[[NSString alloc] initWithData:data
										 encoding:NSUTF8StringEncoding] autorelease]);
	[data release];
	data = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	callback(error, nil);
	[data release];
	data = nil;
}

- (void)dealloc {
	[data release];
	[connection release];
	[callback release];
	[super dealloc];
}

@end
