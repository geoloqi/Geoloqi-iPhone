//
//  LQShareMail.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareMail.h"

@implementation LQShareMail

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message minutes:(NSNumber *)_minutes {

	self.minutes = _minutes;
	
	NSString *subject = @"Track me on Geoloqi!";
	NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		// We must always check whether the current device is configured for sending emails
		if([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
			mailer.mailComposeDelegate = self;
            NSLog(@"Opening mail view controller");
			
			[mailer setSubject:subject];
			
			// Fill out the email body text
			[mailer setMessageBody:body isHTML:NO];

			[self presentModalViewController:mailer];
			[mailer release];
		} else {
			// Mail is not configured, launch the app
			[self launchMailAppOnDeviceWithSubject:subject andBody:body];
		}
	} else {
		// pre iOS 4, so just open the app
		[self launchMailAppOnDeviceWithSubject:subject andBody:body];
	}
}

-(void)launchMailAppOnDeviceWithSubject:(NSString *)subject andBody:(NSString *)body {
	NSString *email = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@", subject, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController*)mailController
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error {
    NSLog(@"mailComposeController:didFinishWithResult:");
    switch (result)
    {
        case MFMailComposeResultCancelled:
			[self shareControllerDidCancel:gAppDelegate.mapViewController];
            break;
        case MFMailComposeResultSaved:
			[LQShareService linkWasSent:@"Draft Saved" minutes:self.minutes];
			[self shareControllerDidFinish:gAppDelegate.mapViewController];
            break;
        case MFMailComposeResultSent:
			[LQShareService linkWasSent:@"Sent" minutes:self.minutes];
			[self shareControllerDidFinish:gAppDelegate.mapViewController];
            break;
        case MFMailComposeResultFailed:
			[self shareControllerDidCancel:gAppDelegate.mapViewController];
            break;
        default:
			[self shareControllerDidCancel:gAppDelegate.mapViewController];
            break;
    }
}

- (void)dealloc 
{
	[super dealloc];
}

@end
