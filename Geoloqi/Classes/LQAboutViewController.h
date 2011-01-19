//
//  LQAbout.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/18/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQAboutViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	BOOL firstLoad;
}

//@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)doneButtonWasTapped:(UIBarButtonItem *)button;

@end
