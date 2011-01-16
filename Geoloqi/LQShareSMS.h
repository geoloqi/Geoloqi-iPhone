//
//  LQShareSMS.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "LQShareService.h"

@interface LQShareSMS : LQShareService <MFMessageComposeViewControllerDelegate> {
	
}

- (void)launchMessageAppOnDevice:(NSString *)body;

@end
