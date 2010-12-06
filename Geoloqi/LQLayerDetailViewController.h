//
//  LQLayerDetailViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/25/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"


@interface LQLayerDetailViewController : UIViewController {
    NSDictionary *layer;
	NSString *layerID;
	IBOutlet UILabel *layerName;
	IBOutlet UIImageView *layerImg;
	IBOutlet UILabel *layerDescription;	
	IBOutlet UIWebView *webView;
	IBOutlet UIButton *activateButton;
	LQHTTPRequestCallback layerActivatedCallback;
}

@property (nonatomic, retain) NSDictionary *layer;

- (id)initWithLayer:(NSDictionary *)_layer;
- (IBAction)tappedActivate:(id)sender;
- (LQHTTPRequestCallback)layerActivatedCallback;

@end
