//
//  LQShareMail.h
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "LQShareService.h"

@interface LQShareMail : LQShareService <MFMailComposeViewControllerDelegate> {
	
}

- (void)launchMailAppOnDeviceWithSubject:(NSString *)subject andBody:(NSString *)body;

@end
