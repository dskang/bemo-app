//
//  LumoAppDelegate.h
//  Lumo
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationRelay.h"
#import "LumoRequest.h"
#import "ContactsManager.h"
#import "CallManager.h"

#define myAppDelegate ((LumoAppDelegate *)[[UIApplication sharedApplication] delegate])
#define BASE_URL @"http://lumo.herokuapp.com"

// Notfications
#define REQUEST_FAILED @"requestFailure"
#define AUTH_FAILED @"auth"

#define LOGIN_SUCCESS @"loginSuccess"
#define GET_FRIENDS_SUCCESS @"getFriendsSuccess"

#define LOC_PUSHED @"locPushed"
#define PARTNER_LOC_UPDATED @"partnerLocUpdated"
#define DISCONNECTED @"disconnected"

#define CONN_REQUESTED @"connRequested"
#define CONN_RECEIVED @"connReceived"
#define CONN_ENDED @"connEnded"

@interface LumoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LocationRelay *locationRelay;
@property (strong, nonatomic) CallManager *callManager;
@property (strong, nonatomic) ContactsManager *contactsManager;
@property (strong, nonatomic) NSString *sessionToken;

@end
