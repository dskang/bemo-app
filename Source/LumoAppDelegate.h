//
//  LumoAppDelegate.h
//  Lumo
//
//  Created by Lumo on 4/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Authentication.h"
#import "LocationRelay.h"
#import "LumoRequest.h"
#import "ContactsManager.h"
#import "CallManager.h"

#define myAppDelegate ((LumoAppDelegate *)[[UIApplication sharedApplication] delegate])
#define BASE_URL @"http://lumo.herokuapp.com"

// User defaults
#define DEVICE_KEY @"deviceKey" // unique device id
#define DEVICE_TOKEN @"deviceToken" // push notification
#define LUMO_SESSION_TOKEN @"LumoSessionToken"

// Notifications
#define PARTNER_IMAGE_UPDATED @"partnerImageUpdated"
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

#define DISCONNECTED @"disconnected"
#define CALL_WAITING @"receive call"

@interface LumoAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) Authentication *auth;
@property (nonatomic, strong) LocationRelay *locationRelay;
@property (nonatomic, strong) CallManager *callManager;
@property (nonatomic, strong) ContactsManager *contactsManager;

@end
