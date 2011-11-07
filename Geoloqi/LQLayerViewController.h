//
//  LQLayerViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "LQLayerDetailViewController.h"
#import "LQLayerCellView.h"
#import "Geoloqi.h"



@interface LQLayerViewController : PullRefreshTableViewController <LQLayerDetailViewControllerDelegate> {
	IBOutlet LQLayerCellView *layerCell;
	NSArray *featuredLayers, *yourLayers, *activeLayers, *inactiveLayers;
	NSDate *lastRefresh;
	NSIndexPath *selectedIndexPath;
	LQHTTPRequestCallback loadLayersCallback;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *layerCell;
@property (nonatomic, retain) NSArray *featuredLayers, *yourLayers, *activeLayers, *inactiveLayers;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

- (NSMutableDictionary *) getLayerAtIndexPath:(NSIndexPath *)indexPath;

@end
