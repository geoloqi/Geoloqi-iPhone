//
//  GeonoteMessageViewController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Geonote;

@interface GeonoteMessageViewController : UIViewController <UITextViewDelegate>
{
    IBOutlet UITextView *textView;
    Geonote *geonote;
}

@property (nonatomic, retain) Geonote *geonote;

- (IBAction)tappedFinish:(id)sender;

@end