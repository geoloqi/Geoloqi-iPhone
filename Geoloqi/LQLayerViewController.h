//
//  LQLayerViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQLayerDetailViewController.h"
#import "LQLayerCellView.h"
#import "Geoloqi.h"


@interface LQLayerViewController : UIViewController <LQLayerDetailViewControllerDelegate> {
	IBOutlet UITableView *layerTable;
	IBOutlet LQLayerCellView *layerCell;
	NSArray *featuredLayers, *yourLayers;
	NSIndexPath *selectedIndexPath;
	LQHTTPRequestCallback loadLayersCallback;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *layerCell;
@property (nonatomic, retain) NSArray *featuredLayers, *yourLayers;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;

- (NSMutableDictionary *) getLayerAtIndexPath:(NSIndexPath *)indexPath;

@end
