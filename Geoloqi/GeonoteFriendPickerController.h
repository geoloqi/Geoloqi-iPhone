//
//  GeonoteFriendPickerController.h
//  Geoloqi
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Geonote;

@interface GeonoteFriendPickerController : UIViewController
{
    Geonote *geonote;
}

@property (nonatomic, retain) Geonote *geonote;

- (IBAction)tappedNext:(id)sender;

@end