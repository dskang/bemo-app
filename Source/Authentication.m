//
//  Authentication.m
//  Lumo
//
//  Created by Dan Kang on 5/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "Authentication.h"
#import "LumoAppDelegate.h"
#import "AFJSONRequestOperation.h"

@interface Authentication()
@property (strong, nonatomic) Facebook *facebook;
@end

@implementation Authentication

@synthesize facebook = _facebook;

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
        [self loginToLumo];
    }
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    // TODO: Only log in when either FB access token or APNS token changes to save bandwidth!
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
 * 
 * Sets notifications:
 * "loginSuccess" upon successful login
 * "auth" upon authentication failure
 ******************************************************************************/
- (void)loginToLumo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceKey = [defaults objectForKey:@"deviceKey"];
    NSString *serviceKey = [defaults objectForKey:@"FBAccessTokenKey"];
    
#if !(TARGET_IPHONE_SIMULATOR)
    NSString *deviceToken = [defaults objectForKey:@"deviceToken"];
#else
    NSString *deviceToken = @"FAKE_DEVICE_TOKEN";
#endif
    
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          deviceKey, @"device_id",
                          deviceToken, @"device_token",
                          @"facebook", @"service",
                          serviceKey, @"service_token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/login", BASE_URL];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest *request, NSHTTPURLResponse*response, id JSON) {
        NSString *status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            myAppDelegate.sessionToken = [JSON valueForKeyPath:@"data.token"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"auth" object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

@end
