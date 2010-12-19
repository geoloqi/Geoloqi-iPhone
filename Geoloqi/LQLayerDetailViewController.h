//
//  LQLayerDetailViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/25/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"

@protocol LQLayerDetailViewControllerDelegate;


@interface LQLayerDetailViewController : UIViewController {
    NSMutableDictionary *layer;
	NSString *layerID;
	IBOutlet UILabel *layerName;
	IBOutlet UIImageView *layerImg;
	IBOutlet UILabel *layerDescription;	
	IBOutlet UIWebView *webView;
	IBOutlet UISwitch *subscribeSwitch;
	LQHTTPRequestCallback layerSubscribeCallback;
	id delegate;
}

@property (nonatomic, retain) NSMutableDictionary *layer;
@property (nonatomic, assign) id <LQLayerDetailViewControllerDelegate> delegate;

- (id)initWithLayer:(NSMutableDictionary *)_layer;
- (IBAction)subscribeChanged:(id)sender;
- (LQHTTPRequestCallback)layerSubscribeCallback;

@end


@protocol LQLayerDetailViewControllerDelegate <NSObject>

- (void) layerDetailViewControllerDidUpdateLayer: (NSMutableDictionary*) layer;

@end