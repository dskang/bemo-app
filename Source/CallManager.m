//
//  CallManager.m
//  Lumo
//
//  Created by Lumo on 5/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "CallManager.h"
#import "AFJSONRequestOperation.h"
#import "LumoAppDelegate.h"

@implementation CallManager

@synthesize partnerInfo = _partnerInfo;

/******************************************************************************
 * Initiate connection to a contact
 ******************************************************************************/
+ (void)initiateConnection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:LUMO_SESSION_TOKEN];
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (sessionToken && partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/init", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"iphone", @"device",
                              @"facebook", @"service",
                              sessionToken, @"token", nil];
        [LumoRequest postRequestToURL:url withDict:dict successNotification:CONN_REQUESTED];
    }
}

/******************************************************************************
 * Receive connection from a contact
 ******************************************************************************/
+ (void)receiveConnection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:LUMO_SESSION_TOKEN];
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (sessionToken && partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/receive", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"iphone", @"device",
                              sessionToken, @"token", nil];
        [LumoRequest postRequestToURL:url withDict:dict successNotification:CONN_RECEIVED];
    }
}

/******************************************************************************
 * End an active connection
 ******************************************************************************/
+ (void)endConnection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:LUMO_SESSION_TOKEN];
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (sessionToken && partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: sessionToken, @"token", nil];
        [LumoRequest postRequestToURL:url withDict:dict successNotification:CONN_ENDED];
    }
}

@end
