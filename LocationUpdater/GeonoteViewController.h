//
//  GeonoteViewController.h
//  LocationUpdater
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Code Sorcery Workshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GeonoteViewController : UIViewController <MKMapViewDelegate>
{
    MKMapView *mapView;
    UITextField *queryField;
    UIButton *findMeButton;
    UILabel *radiusLabel;
    UISlider *radiusSlider;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UITextField *queryField;
@property (nonatomic, retain) IBOutlet UIButton *findMeButton;
@property (nonatomic, retain) IBOutlet UILabel *radiusLabel;
@property (nonatomic, retain) IBOutlet UISlider *radiusSlider;

- (IBAction)tappedFindMe:(id)sender;
- (IBAction)adjustedRadius:(id)sender;

@end
