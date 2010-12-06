//
//  LQConstants.h
//  Geoloqi
//
//  Created by Justin R. Miller on 10/5/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

// Geoloqi client credentials for talking to the API
#define LQ_OAUTH_CLIENT_ID	@"geoloqi"
#define LQ_OAUTH_SECRET		@"1234"

// Urban Airship for push notifications
#define UAApplicationKey			@""
#define UAApplicationSecret			@""

// Facebook application key for sharing on Facebook
#define SHKFacebookUseSessionProxy  NO 
#define SHKFacebookKey				@""
#define SHKFacebookSecret			@""
#define SHKFacebookSessionProxyURL  @""

// Twitter application key for sharing on Twitter
#define SHKTwitterConsumerKey		@""
#define SHKTwitterSecret			@""
#define SHKTwitterCallbackUrl		@"http://geoloqi.com/blog/" // You need to set this if using OAuth, see note above (xAuth users can skip it)
#define SHKTwitterUseXAuth			0 // To use xAuth, set to 1
#define SHKTwitterUsername			@"geoloqi" // Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
