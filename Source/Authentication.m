//
//  Authentication.m
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "Authentication.h"
#import "BemoAppDelegate.h"
#import "AFJSONRequestOperation.h"

@implementation Authentication

@synthesize facebook = _facebook;
@synthesize loginRequired;
@synthesize facebookLoginRequired;

/******************************************************************************
 * Getters
 ******************************************************************************/
- (Facebook *)facebook {
    if (!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:@"264787203622632" andDelegate:self];
    }
    return _facebook;
}

/******************************************************************************
 * Facebook
 ******************************************************************************/
- (void)loginToFB {
#ifdef DEBUG
    NSLog(@"Logging into Facebook.");
#endif
    // Check for previously saved access token information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.facebook isSessionValid] || facebookLoginRequired) {
        [self.facebook authorize:nil];
    } else {
        // Only log in if user's info changed
        if (self.loginRequired) {
            [self loginToBemo];
        } else {
#ifdef DEBUG
            NSLog(@"Skipped Bemo login.");
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:self];
        }
    }
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    self.facebookLoginRequired = NO;
    
    // Update server with new Facebook credentials
    [self loginToBemo];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login"
                                                    message:@"You must login to Facebook to use Bemo"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self authenticate];
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    
}

- (void)fbDidLogout {
    
}

- (void)fbSessionInvalidated {
    [self authenticate];
}

/******************************************************************************
 * Bemo
 ******************************************************************************/
- (void)authenticate {
    [self loginToFB];
}

/******************************************************************************
 * Login to the Bemo server
 ******************************************************************************/
- (void)loginToBemo {
#ifdef DEBUG
    NSLog(@"Logging into Bemo.");
#endif
    NSString *url = [NSString stringWithFormat:@"%@/login", BASE_URL];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceKey = [defaults objectForKey:DEVICE_KEY];
    NSString *serviceKey = [defaults objectForKey:@"FBAccessTokenKey"];
    NSString *deviceType = [UIDevice currentDevice].model;
    
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *deviceToken = [defaults objectForKey:DEVICE_TOKEN];
#else
    NSString *deviceToken = @"FAKE_DEVICE_TOKEN";
#endif

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          deviceType, @"device",
                          deviceKey, @"device_id",
                          deviceToken, @"device_token",
                          @"facebook", @"service",
                          serviceKey, @"service_token", nil];
    [BemoRequest postRequestToURL:url withDict:dict successNotification:LOGIN_SUCCESS];

    self.loginRequired = NO;
}

@end
