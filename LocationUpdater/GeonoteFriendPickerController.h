//
//  GeonoteFriendPickerController.h
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/26/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
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