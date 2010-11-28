//
//  GeonoteMessageViewController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geoloqi.h"


@class Geonote;

@interface GeonoteMessageViewController : UIViewController <UITextViewDelegate>
{
    IBOutlet UITextView *textView;
    Geonote *geonote;
	GLHTTPRequestCallback geonoteSentCallback;
}

@property (nonatomic, retain) Geonote *geonote;

- (GLHTTPRequestCallback)geonoteSentCallback;

- (IBAction)tappedFinish:(id)sender;

@end