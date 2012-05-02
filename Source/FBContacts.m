//
//  FBContacts.m
//  Lumo
//
//  Created by Harvest Zhang on 4/19/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "FBContacts.h"
#import "LumoAppDelegate.h"

@interface FBContacts ()
@property (nonatomic) BOOL infoLoaded;
@end

@implementation FBContacts
@synthesize delegate = _delegate;
@synthesize infoLoaded = _infoLoaded;

- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([request.url isEqualToString:@"https://graph.facebook.com/me"]) {
        NSLog(@"Got my contact info.");
        myAppDelegate.myFBinfo = (NSDictionary*)result;
    }
    else if ([request.url isEqualToString:@"https://graph.facebook.com/me/friends"]) {
        NSLog(@"Got my friends' contact info.");
        myAppDelegate.contactArray = (NSDictionary*)result;
    }
    if (self.infoLoaded) [[self delegate] contactsAcquired:YES]; 
    else self.infoLoaded = TRUE;
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Uh oh, request failure.");
}

- (void)requestContacts {
    NSLog(@"Request sending...");
    self.infoLoaded = NO;
    Facebook *facebook = myAppDelegate.facebook;
    [facebook requestWithGraphPath:@"me/friends" andDelegate:self];
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    NSLog(@"Request sent.");
}

@end