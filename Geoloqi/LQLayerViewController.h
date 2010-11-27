//
//  LQLayerViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQLayerCellView.h"
#import "GLHTTPRequestLoader.h"


@interface LQLayerViewController : UIViewController {
	IBOutlet UITableView *layerTable;
	IBOutlet LQLayerCellView *layerCell;
	NSMutableArray *featuredLayers, *yourLayers;
	GLHTTPRequestCallback loadLayersCallback;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *layerCell;
@property (nonatomic, retain) NSMutableArray *featuredLayers, *yourLayers;

@end
