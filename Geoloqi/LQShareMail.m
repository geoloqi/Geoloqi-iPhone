//
//  LQShareMail.m
//  Geoloqi
//
//  Created by Aaron Parecki on 1/15/11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "LQShareMail.h"

@implementation LQShareMail

@synthesize controller;

- (void)shareURL:(NSURL *)url withMessage:(NSString *)message fromController:(UIViewController *)_controller {
	self.controller = _controller;
	
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
			[mailController dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSaved:
			[self.controller.parentViewController dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSent:
			[self.controller.parentViewController dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultFailed:
			[mailController dismissModalViewControllerAnimated:YES];
            break;
        default:
			[mailController dismissModalViewControllerAnimated:YES];
            break;
    }
}


- (void)dealloc 
{
	[controller release];
	[super dealloc];
}

@end
