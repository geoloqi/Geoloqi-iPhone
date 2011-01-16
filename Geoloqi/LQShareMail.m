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
	
	// We must always check whether the current device is configured for sending emails
	if([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		mailer.mailComposeDelegate = self;
		
		[mailer setSubject:@"Track me on Geoloqi!"];
		
		// Fill out the email body text
		[mailer setMessageBody:[message stringByAppendingFormat:@" %@", [url absoluteString]] 
						isHTML:NO];
		
		[self.controller presentModalViewController:mailer animated:YES];
		[mailer release];
	}
	else
	{
		// Notify the user that mail is not configured
	}
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
			[self shareControllerDidFinish];
            break;
        case MFMailComposeResultSent:
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
