//
//  ContactsManager.m
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "ContactsManager.h"
#import "BemoAppDelegate.h"
#import "AFJSONRequestOperation.h"

@implementation ContactsManager

@synthesize sections = _sections;

/******************************************************************************
 * Format the array of contacts in alphabetized and indexed order
 ******************************************************************************/
- (void)organizeContactArray:(NSArray *)unsortedContacts {
    // Clear sections
    self.sections = [[NSMutableDictionary alloc] init];

    // Sort the contacts by first name
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedArray = [unsortedContacts sortedArrayUsingDescriptors:
                           [NSArray arrayWithObject:descriptor]];
    
    // Insert contacts into appropriate sections
    for (NSDictionary *contact in sortedArray) {
        NSString *sectionIndexTitle = [[contact valueForKey:@"name"] substringToIndex:1];
        // Create section if it does not exist
        if (![self.sections.allKeys containsObject:sectionIndexTitle]) {
            [self.sections setValue:[[NSMutableArray alloc] init] forKey:sectionIndexTitle];
        }
        NSMutableArray *contacts = [self.sections valueForKey:sectionIndexTitle];
        [contacts addObject:contact];
    }
}

/******************************************************************************
 * Get FB friends who use the app, save to app delegate
 *
 * Sets notifications:
 * GET_FRIENDS_SUCCESS for successful friend retrieval
 ******************************************************************************/
+ (void)getFriends {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:BEMO_SESSION_TOKEN];
    NSString *partnerUrl = [NSString stringWithFormat:@"%@/friends?token=%@", BASE_URL, sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"success"]) {
            [myAppDelegate.contactsManager organizeContactArray:[JSON objectForKey:@"data"]];
#ifdef DEBUG
            NSLog(@"Notification: %@", GET_FRIENDS_SUCCESS);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:GET_FRIENDS_SUCCESS object:self]; 
        } else {
            NSString *error = [JSON valueForKey:@"error"];
#ifdef DEBUG
            NSLog(@"Error Notification: %@", error);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:error object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSDictionary *requestInfo = [NSDictionary dictionaryWithObject:partnerUrl forKey:@"url"];
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self userInfo:requestInfo];
        // Try to get contacts again
        [self getFriends];
    }];
    [operation start];
}

- (void)getPartnerImage {
    NSString *partnerID = [myAppDelegate.callManager.partnerInfo valueForKeyPath:@"service.id"];
    if (partnerID) {
        NSString *url = [NSString stringWithFormat:@"%@/picture?type=large", partnerID];
        [myAppDelegate.auth.facebook requestWithGraphPath:url andDelegate:self];
    }
}

# pragma mark FBRequestDelegate

- (void)requestLoading:(FBRequest *)request {

}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"FB error: %@", error);
#endif
}

- (void)request:(FBRequest *)request didLoad:(id)result {

}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    [myAppDelegate.callManager.partnerInfo setValue:image forKey:@"image"];
#ifdef DEBUG
    NSLog(@"Notification: %@", PARTNER_IMAGE_UPDATED);
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:PARTNER_IMAGE_UPDATED object:self];
}

@end
