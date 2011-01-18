//
//  LQLayerCellView.m
//  Geoloqi
//
//  Created by Aaron Parecki on 11/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "LQLayerCellView.h"
#import "PKHTTPCachedImage.h"

@implementation LQLayerCellView

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewStylePlain reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[cellText release];
	cellText = nil;
	[descriptionText release];
	descriptionText = nil;
	[layerImg release];
	layerImg = nil;
    [super dealloc];
}

- (void)setLabelText:(NSString *)_text {
	cellText.text = _text;
}

- (void)setDescpText:(NSString *)_text {
	descriptionText.text = _text;
}

- (void)setLayerImage:(NSString *)_url {
	[[PKHTTPCachedImage sharedInstance] setImageForView:layerImg withURL:_url];
}

@end
