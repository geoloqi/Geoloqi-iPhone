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
	NSString *layerID;
	IBOutlet UILabel *layerName;
	IBOutlet UIImageView *layerImg;
	IBOutlet UILabel *layerDescription;	
	IBOutlet UIWebView *webView;
	IBOutlet UIButton *activateButton;
	GLHTTPRequestCallback layerActivatedCallback;
}

@property (nonatomic, retain) NSString *layerID;

- (void)setLayerName:(NSString *)_text;
- (void)setLayerDescription:(NSString *)_text;
- (void)setLayerImage:(NSString *)_url;
- (void)setLayerHTMLView:(NSString *)_url;
- (void)setButtonText:(NSString *)_text;
- (IBAction)tappedActivate:(id)sender;
- (GLHTTPRequestCallback)layerActivatedCallback;

@end
