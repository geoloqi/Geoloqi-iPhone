//
//  LQShareTwitter.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LQShareService.h"
#import "LQShareTwitterViewController.h"

@interface LQShareTwitter : LQShareService <LQShareTwitterDelegate> {
	LQShareTwitterViewController *shareView;
}

@property (nonatomic, retain) LQShareTwitterViewController *shareView;

@end
