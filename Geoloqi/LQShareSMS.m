//
//  LQShareSMS.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareSMS.h"


@implementation LQShareSMS

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes {

	self.minutes = _minutes;

	NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];
	
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	if (messageClass != nil) {
		// We must always check whether the current device is configured for sending SMSs
		if([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *mailer = [[MFMessageComposeViewController alloc] init];
			mailer.messageComposeDelegate = self;
			
			// Fill out the email body text
			[mailer setBody:body];
			
			[self presentModalViewController:mailer];
			[mailer release];
		} else {
			// SMS is not configured, (i.e. on an iPod touch or in the simulator), launch the SMS app
			[self launchMessageAppOnDevice:body];
		}
	} else {
		// pre iOS 4, so just open the app
		[self launchMessageAppOnDevice:body];
	}
}

-(void)launchMessageAppOnDevice:(NSString *)body {
	// TODO: Apparently Apple doesn't support setting the body of SMSs in a link, so 
	// copy the body text to the clipboard instead.
	
	[[UIPasteboard generalPasteboard] setString:body];
	
	NSString *sms = [NSString stringWithFormat:@"sms:?body=%@", body];
	sms = [sms stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:sms]];
}

- (void)messageComposeViewController:(MFMessageComposeViewController*)messageController
		  didFinishWithResult:(MessageComposeResult)result {
    switch (result)
    {
        case MessageComposeResultCancelled:
			[self shareControllerDidCancel:gAppDelegate.mapViewController];
            break;
        case MessageComposeResultSent:
			[LQShareService linkWasSent:@"Sent" minutes:self.minutes];
			[self shareControllerDidFinish:gAppDelegate.mapViewController];
            break;
        case MessageComposeResultFailed:
			[self shareControllerDidCancel:gAppDelegate.mapViewController];
            break;
        default:
			[self shareControllerDidCancel:gAppDelegate.mapViewController];
            break;
    }
}


@end
