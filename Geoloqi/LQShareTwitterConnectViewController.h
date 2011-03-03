//
//  LQShareTwitterConnectViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/16/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LQShareTwitterConnectDelegate;


@interface LQShareTwitterConnectViewController : UIViewController {
	UIWebView *webView;
	UIBarButtonItem *cancelButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, assign) id <LQShareTwitterConnectDelegate> delegate;

- (void)cancelWasTapped:(id)sender;

@end


@protocol LQShareTwitterConnectDelegate <NSObject>
- (void)userConnectedTwitter;
@end