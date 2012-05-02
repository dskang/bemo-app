//
//  LumoAppDelegate.m
//  Lumo
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "LumoAppDelegate.h"

@implementation LumoAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize locationRelay = _locationRelay;
@synthesize contactArray = _contactArray;
@synthesize myFBinfo = _myFBinfo;
@synthesize contactFBinfo = _contactFBinfo;
@synthesize sessionToken = _sessionToken;

- (Facebook *)facebook {
    if (!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:@"407078449305300" andDelegate:self];
    }
    return _facebook;
}

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
    }
}

- (void)loginToLumo {
    if (!_locationRelay) _locationRelay = [[LocationRelay alloc] init];
    [self.locationRelay loginToLumo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLumoFriends) name:@"loginSuccess" object:nil];
}

- (void)getLumoFriends {
    NSLog(@"Login successful. Session token is %@", self.sessionToken); //HEFFALUMPS
    [self.locationRelay getFriends];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAndFriendsDone) name:@"getFriendsSuccess" object:nil];
}

- (void)loginAndFriendsDone {
    NSLog(@"Getting friends successful."); //HEFFALUMPS
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAndFriendsSuccess" object:self];
}

- (void)generateDeviceKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* deviceKey;
    if (!(deviceKey = [defaults objectForKey:@"deviceKey"])) {
        CFUUIDRef newDeviceKey = CFUUIDCreate(NULL);
        deviceKey = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, newDeviceKey);
        [defaults setObject:deviceKey forKey:@"deviceKey"];
        CFRelease(newDeviceKey);
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
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt {
    
}

- (void)fbDidLogout {
    
}

- (void)fbSessionInvalidated {
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self loginToFB];
    [self generateDeviceKey];
    [self loginToLumo];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
