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

/******************************************************************************
 * Initiate connection to a contact
 ******************************************************************************/
+ (void)initiateConnection {
    NSString *url = [NSString stringWithFormat:@"%@/call/%@/init", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          @"facebook", @"service",
                          myAppDelegate.sessionToken, @"token", nil];
[LumoRequest postRequestToURL:url withDict:dict successNotification:@"connRequested"];
}

/******************************************************************************
 * Receive connection from a contact
 ******************************************************************************/
+ (void)receiveConnection {
    NSString *url = [NSString stringWithFormat:@"%@/call/%@/receive", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          myAppDelegate.sessionToken, @"token", nil];
[LumoRequest postRequestToURL:url withDict:dict successNotification:@"connReceived"];
}

/******************************************************************************
 * End an active connection
 ******************************************************************************/
+ (void)endConnection {
    NSString *url = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: myAppDelegate.sessionToken, @"token", nil];
[LumoRequest postRequestToURL:url withDict:dict successNotification:@"connEnded"];
}

@end
