//
//  LQLayerViewController.h
//  Geoloqi
//
//  Created by Aaron Parecki on 11/23/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQLayerCellView.h"


@interface LQLayerViewController : UIViewController {
	IBOutlet UITableView *layerTable;
	IBOutlet LQLayerCellView *layerCell;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *layerCell;

@end
