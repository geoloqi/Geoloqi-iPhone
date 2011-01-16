//
//  LQShareTwitterViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQShareTwitterViewController : UIViewController {
	id delegate;
}

@property (nonatomic, retain) id delegate;

- (IBAction)cancelWasTapped;

@end


@protocol LQShareTwitterDelegate
- (void)twitterDidCancel;
- (void)twitterDidFinish;
@end