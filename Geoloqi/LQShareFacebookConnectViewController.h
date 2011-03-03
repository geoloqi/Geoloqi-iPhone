//
//  LQShareFacebookConnectViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/17/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LQShareFacebookConnectDelegate;

@interface LQShareFacebookConnectViewController : UIViewController {
	UIWebView *webView;
	UIBarButtonItem *cancelButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;
@property (nonatomic, assign) id <LQShareFacebookConnectDelegate> delegate;

- (void)cancelWasTapped:(id)sender;

@end

@protocol LQShareFacebookConnectDelegate <NSObject>
- (void)userConnectedFacebook;
@end