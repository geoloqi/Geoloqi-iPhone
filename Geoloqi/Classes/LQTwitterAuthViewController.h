//
//  LQTwitterAuthViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 2011-02-26.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQTwitterAuthViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)cancel;

@end
