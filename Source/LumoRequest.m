//
//  LumoRequest.m
//  Lumo
//
//  Created by Dan Kang on 5/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "LumoAppDelegate.h"
#import "LumoRequest.h"
#import "AFJSONRequestOperation.h"

@implementation LumoRequest

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
            [[NSNotificationCenter defaultCenter] postNotificationName:successNotification object:self userInfo:JSON];
            NSLog(@"Notification: %@", successNotification);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[JSON valueForKeyPath:@"error"] object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self];
    }];
    [operation start];
}

@end
