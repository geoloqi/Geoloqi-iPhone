//
//  GeonoteConfirmationViewController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Geonote;

@interface GeonoteConfirmationViewController : UIViewController
{
    IBOutlet UILabel *geonoteSummaryLabel;
    Geonote *geonote;
}

@property (nonatomic, retain) Geonote *geonote;

- (IBAction)dismiss:(id)sender;

@end