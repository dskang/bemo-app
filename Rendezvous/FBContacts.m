//
//  FBContacts.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/19/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "FBContacts.h"
#import "RendezvousAppDelegate.h"

@implementation FBContacts
@synthesize contactArray = _contactArray;

- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"Ah hah, got contact results!");
    _contactArray = (NSArray*)result;
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Uh oh, request failure.");
}

- (void)requestContacts {
    NSLog(@"Request sending...");
    Facebook *facebook = myAppDelegate.facebook;
    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
    NSLog(@"Request sent.");
}

@end