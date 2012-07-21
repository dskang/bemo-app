//
//  BemoRequest.m
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "BemoAppDelegate.h"
#import "BemoRequest.h"
#import "AFJSONRequestOperation.h"

@implementation BemoRequest

// TODO: Convert code to use AFHTTPClient!
+ (void)postRequestToURL:(NSString *)url withDict:(NSDictionary *)dict successNotification:(NSString *)successNotification  {
    // Convert data to JSON
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        

    // Form POST request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];

    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"success"]) {
#ifdef DEBUG
            NSLog(@"Notification: %@", successNotification);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:successNotification object:self userInfo:JSON];
        } else {
            NSString *error = [JSON valueForKey:@"error"];
#ifdef DEBUG
            NSLog(@"Error Notification: %@", error);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:error object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSDictionary *requestInfo = [NSDictionary dictionaryWithObject:url forKey:@"url"];
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self userInfo:requestInfo];
    }];
    [operation start];
}

@end
