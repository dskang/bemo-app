//
//  CallManager.m
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "CallManager.h"
#import "AFJSONRequestOperation.h"
#import "BemoAppDelegate.h"

@implementation CallManager

@synthesize partnerInfo = _partnerInfo;

/******************************************************************************
 * Initiate connection to a contact
 ******************************************************************************/
+ (void)initiateConnection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:BEMO_SESSION_TOKEN];
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    NSString *deviceType = [UIDevice currentDevice].model;
    if (sessionToken && partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/init", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              deviceType, @"device",
                              @"facebook", @"service",
                              sessionToken, @"token", nil];
        [BemoRequest postRequestToURL:url withDict:dict successNotification:CONN_REQUESTED];
    }
}

/******************************************************************************
 * Receive connection from a contact
 ******************************************************************************/
+ (void)receiveConnection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:BEMO_SESSION_TOKEN];
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    NSString *deviceType = [UIDevice currentDevice].model;
    if (sessionToken && partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/receive", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              deviceType, @"device",
                              sessionToken, @"token", nil];
        [BemoRequest postRequestToURL:url withDict:dict successNotification:CONN_RECEIVED];
    }
}

/******************************************************************************
 * End an active connection
 ******************************************************************************/
+ (void)endConnection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:BEMO_SESSION_TOKEN];
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKey:@"id"];
    if (sessionToken && partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, partnerID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: sessionToken, @"token", nil];
        [BemoRequest postRequestToURL:url withDict:dict successNotification:CONN_ENDED];
    }
}

+ (void)endConnectionWithID:(NSString *)targetID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:BEMO_SESSION_TOKEN];
    if (sessionToken && targetID) {
        NSString *url = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, targetID];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: sessionToken, @"token", nil];
        [BemoRequest postRequestToURL:url withDict:dict successNotification:CONN_ENDED];
    }
}

@end
