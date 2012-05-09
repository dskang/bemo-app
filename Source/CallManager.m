//
//  CallManager.m
//  Lumo
//
//  Created by Dan Kang on 5/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
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
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/init", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"iphone", @"device",
                              @"facebook", @"service",
                              myAppDelegate.sessionToken, @"token", nil];
        [LumoRequest postRequestToURL:url withDict:dict successNotification:CONN_REQUESTED];
    }
}

/******************************************************************************
 * Receive connection from a contact
 ******************************************************************************/
+ (void)receiveConnection {
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/receive", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"iphone", @"device",
                              myAppDelegate.sessionToken, @"token", nil];
        [LumoRequest postRequestToURL:url withDict:dict successNotification:CONN_RECEIVED];
    }
}

/******************************************************************************
 * End an active connection
 ******************************************************************************/
+ (void)endConnection {
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: myAppDelegate.sessionToken, @"token", nil];
        [LumoRequest postRequestToURL:url withDict:dict successNotification:CONN_ENDED];
    }
}

@end
