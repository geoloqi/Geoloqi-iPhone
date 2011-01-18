//
//  LQShareMail.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareMail.h"

@implementation LQShareMail

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message {
	
	NSString *subject = @"Track me on Geoloqi!";
	NSString *body = [message stringByAppendingFormat:@" %@", [url absoluteString]];
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		// We must always check whether the current device is configured for sending emails
		if([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
			mailer.mailComposeDelegate = self;
			
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
    switch (result)
    {
        case MFMailComposeResultCancelled:
			[self shareControllerDidCancel:mailController];
            break;
        case MFMailComposeResultSaved:
			[LQShareService linkWasSent:@"Draft Saved"];
			[self shareControllerDidFinish];
            break;
        case MFMailComposeResultSent:
			[LQShareService linkWasSent:@"Sent"];
			[self shareControllerDidFinish];
            break;
        case MFMailComposeResultFailed:
			[self shareControllerDidCancel:mailController];
            break;
        default:
			[self shareControllerDidCancel:mailController];
            break;
    }
}

- (void)dealloc 
{
	[super dealloc];
}

@end
