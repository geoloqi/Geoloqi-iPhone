//
//  LQLayerCellView.h
//  Geoloqi
//
//  Created by Amber Case and Aaron Parecki on 11/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LQLayerCellView : UITableViewCell {
	IBOutlet UILabel *cellText;
	IBOutlet UIImageView *productImg;
	IBOutlet UILabel *descriptionText;
}

- (void)setLabelText:(NSString *)_text;
- (void)setDescpText:(NSString *)_text;
- (void)setProductImage:(NSString *)_text;

@end
