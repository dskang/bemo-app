//
//  Authentication.m
//  Lumo
//
//  Created by Lumo on 5/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "Authentication.h"
#import "LumoAppDelegate.h"
#import "AFJSONRequestOperation.h"

@implementation Authentication

@synthesize facebook = _facebook;
@synthesize loginRequired;

/******************************************************************************
 * Getters
 ******************************************************************************/
- (Facebook *)facebook {
    if (!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:@"234653946634375" andDelegate:self];
    }
    return _facebook;
}

/******************************************************************************
 * Facebook
 ******************************************************************************/
- (void)loginToFB {
    NSLog(@"Logging into Facebook.");
    // Check for previously saved access token information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:nil];
    } else {
        // Only log in if user's info changed
        if (self.loginRequired) {
            [self loginToLumo];
        } else {
            NSLog(@"Skipped Lumo login.");
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:self];
        }
    }
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self loginToLumo];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    
}

- (void)fbDidLogout {
    
}

- (void)fbSessionInvalidated {
    
}

/******************************************************************************
 * Lumo
 ******************************************************************************/
- (void)authenticate {
    [self loginToFB];
}

/******************************************************************************
 * Login to the Lumo server
 ******************************************************************************/
- (void)loginToLumo {
    NSLog(@"Logging into Lumo.");
    NSString *url = [NSString stringWithFormat:@"%@/login", BASE_URL];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceKey = [defaults objectForKey:DEVICE_KEY];
    NSString *serviceKey = [defaults objectForKey:@"FBAccessTokenKey"];
    
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *deviceToken = [defaults objectForKey:DEVICE_TOKEN];
#else
    NSString *deviceToken = @"FAKE_DEVICE_TOKEN";
#endif

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          deviceKey, @"device_id",
                          deviceToken, @"device_token",
                          @"facebook", @"service",
                          serviceKey, @"service_token", nil];
    [LumoRequest postRequestToURL:url withDict:dict successNotification:LOGIN_SUCCESS];

    self.loginRequired = NO;
}

@end
