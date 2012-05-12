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
#import "TestFlight.h"

#ifndef DEBUG
#define DEBUG 0
#endif

// TestFlight
#define NSLog TFLog

#define myAppDelegate ((LumoAppDelegate *)[[UIApplication sharedApplication] delegate])
#define BASE_URL @"http://lumo.herokuapp.com"

// User defaults
#define DEVICE_KEY @"deviceKey" // unique device id
#define DEVICE_TOKEN @"deviceToken" // push notification
#define LUMO_SESSION_TOKEN @"LumoSessionToken"

// Intervals in seconds
#define CONNECTING_POLL_INTERVAL 3
#define PARTNER_LOC_POLL_INTERVAL 3

// User states
#define IDLE_STATE @"idleState" // user is idle
#define CONNECTING_STATE @"connectingState" // user is making a connection
#define RECEIVING_STATE @"receivingState" // user is receiving a connection
#define MAP_STATE @"mapState" // user is in a connection

// Notifications
#define PARTNER_IMAGE_UPDATED @"partnerImageUpdated"
#define REQUEST_FAILED @"requestFailure"
#define AUTH_FAILED @"auth"

#define LOGIN_SUCCESS @"loginSuccess"
#define GET_FRIENDS_SUCCESS @"getFriendsSuccess"

#define LOC_PUSHED @"locPushed"
#define PARTNER_LOC_UPDATED @"partnerLocUpdated"
#define DISCONNECTED @"disconnected"

#define CONN_REQUESTED @"connRequested" // user successfully requested a connection
#define CONN_RECEIVED @"connReceived" // user successfully received a connection
#define CONN_ENDED @"connEnded" // user successfully ended a connection

#define DISCONNECTED @"disconnected" // connection was disconnected
#define CONN_WAITING @"receive call" // there is a connection waiting to be received
#define CONN_ESTABLISHED @"connEstablished" // connection was successfully established

@interface LumoAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSString *appState;
@property (nonatomic, strong) Authentication *auth;
@property (nonatomic, strong) LocationRelay *locationRelay;
@property (nonatomic, strong) CallManager *callManager;
@property (nonatomic, strong) ContactsManager *contactsManager;

@end
