//
//  LQLayerDetailViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/25/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLAuthenticationManager.h"


@interface LQLayerDetailViewController : UIViewController {
	NSDictionary *layer;
	IBOutlet UILabel *layerName;
	IBOutlet UIImageView *layerImg;
	IBOutlet UILabel *layerDescription;	
	IBOutlet UIWebView *webView;
	IBOutlet UIButton *activateButton;
	GLHTTPRequestCallback layerActivatedCallback;
}

@property (nonatomic, retain) NSDictionary *layer;

- (IBAction)tappedActivate:(id)sender;
- (GLHTTPRequestCallback)layerActivatedCallback;

@end
