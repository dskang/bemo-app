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
 *
 * Sets notifications:
 * "connRequested" for successful requesting of a call
 * "auth" upon authentication failure
 ******************************************************************************/
+ (void)initiateConnection {
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          @"facebook", @"service",
                          myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/init", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connRequested" object:self];
            NSLog(@"LocationRelay.m | initiateConnection(): init request succeeded!");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"auth" object:self];  
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * Receive connection from a contact
 * (Push notification MUST establish caller ID!)
 *
 * Sets notifications:
 * "connReceived" for successful reception of a call
 * "disconnected" if the caller disconnected
 * "auth" upon authentication failure
 ******************************************************************************/
+ (void)receiveConnection {
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/receive", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connReceived" object:self];
            NSLog(@"LocationRelay.m | receiveConnection(): Connection successfully received!");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[JSON valueForKeyPath:@"error"] object:self];  
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * End an active connection
 *
 * Sets notifications:
 * "connEnded" for successful ending of a connection
 * "auth" upon authentication failure
 ******************************************************************************/
+ (void)endConnection {
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connEnded" object:self];
            NSLog(@"LocationRelay.m | endConnection(): Connection successfully ended!");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[JSON valueForKeyPath:@"error"] object:self];  
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

@end
