//
//  ContactsManager.m
//  Lumo
//
//  Created by Dan Kang on 5/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ContactsManager.h"
#import "LumoAppDelegate.h"
#import "AFJSONRequestOperation.h"

@implementation ContactsManager

@synthesize contactsArray = _contactsArray;

/******************************************************************************
 * Format the array of contacts in alphabetized and indexed order
 ******************************************************************************/
+ (void)setContactArray:(NSArray *)unsortedContacts {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray * alphaArray = [unsortedContacts sortedArrayUsingDescriptors:
                             [NSArray arrayWithObject:descriptor]];
    myAppDelegate.contactArray = alphaArray;
}

/******************************************************************************
 * Get FB friends who use the app, save to app delegate
 *
 * Sets notifications:
 * GET_FRIENDS_SUCCESS for successful friend retrieval
 ******************************************************************************/
+ (void)getFriends {
    NSString *partnerUrl = [NSString stringWithFormat:@"%@/friends?token=%@", BASE_URL, myAppDelegate.sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"success"]) {
            [self setContactArray:[JSON objectForKey:@"data"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_FRIENDS_SUCCESS object:self]; 
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self];
    }];
    [operation start];
}

@end
