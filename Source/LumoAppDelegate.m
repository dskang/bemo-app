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
@synthesize myInfo = _myInfo;
@synthesize contactInfo = _contactInfo;
@synthesize sessionToken = _sessionToken;

- (Facebook *)facebook {
    if (!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:@"234653946634375" andDelegate:self];
    }
    return _facebook;
}

- (LocationRelay *)locationRelay {
    if (!_locationRelay) {
        _locationRelay = [[LocationRelay alloc] init];
    }
    return _locationRelay;
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
- (void)loginToLumo {
    // TODO: Only log in when either FB access token or APNS token changes to save bandwidth!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLumoFriends) name:@"loginSuccess" object:nil];
    [self.locationRelay loginToLumo];
}

- (void)getLumoFriends {
    NSLog(@"LumoAppDelegate | getLumoFriends(): Login successful. Session token is %@", self.sessionToken);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAndFriendsDone) name:@"getFriendsSuccess" object:nil];
    [self.locationRelay getFriends];
}

- (void)loginAndFriendsDone {
    NSLog(@"LumoAppDelegate | loginAndFriendsDone(): Getting friends successful.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAndFriendsSuccess" object:self];
}

- (void)serverFailure {
    NSLog(@"LumoAppDelegate | serverFailure(): Uh oh, massive server failure.");
}

- (void)authFailure {
    NSLog(@"LumoAppDelegate | authFailure(): Uh oh, auth failure.");
}

/******************************************************************************
 * Device ID generation
 ******************************************************************************/
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

/******************************************************************************
 * Application states
 ******************************************************************************/
// Application launched from a non-running state
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Check if app was opened from a push notification
    if (launchOptions)
	{
		NSDictionary* incomingCall = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (incomingCall)
		{
            NSArray *args = [[[incomingCall objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"loc-args"];
            NSString *sourceName = [args objectAtIndex:0];
            NSString *sourceID = [incomingCall objectForKey:@"source_id"];
            [self receiveCallFromSourceName:sourceName sourceID:sourceID];
		}
    }
    
    // Register for push notification
#if !(TARGET_IPHONE_SIMULATOR)
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    
    // Generate device ID if necessary
    [self generateDeviceKey];
    
    // Create notification observer for server failure or auth failure
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverFailure) name:@"serverFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authFailure) name:@"auth" object:nil];
    
    // Authentication on FB and Lumo (FB authentication calls Lumo auth)
    [self loginToFB];
    
    return YES;
}

- (void)receiveCallFromSourceName:(NSString *)sourceName sourceID:(NSString *)sourceID {
    // FIXME: Currently automatically accepting call
    // Save contact info
    // FIXME: Save source's name
    self.contactInfo = [NSDictionary dictionaryWithObjectsAndKeys:sourceID, @"id", sourceName, @"name", nil];
    // Push location
    // FIXME: This is a temporary fix to have a location on the server so that poll will return successfully
    [self.locationRelay pushLocation];
    // Receive call
    [self.locationRelay receiveConnection];
}

// Called when notifcation comes in while app is active or suspended
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)incomingCall
{
    NSArray *args = [[[incomingCall objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"loc-args"];
    NSString *sourceName = [args objectAtIndex:0];
	NSString *sourceID = [incomingCall objectForKey:@"source_id"];
    // TODO: Show accept or decline screen
    [self receiveCallFromSourceName:sourceName sourceID:sourceID];
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

/******************************************************************************
 * Push notifications
 ******************************************************************************/
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* token;
    if (![defaults objectForKey:@"deviceToken"]) {
        token = [[[deviceToken description]
                  stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                 stringByReplacingOccurrencesOfString:@" " withString:@""];
        [defaults setObject:token forKey:@"deviceToken"];
    }
	NSLog(@"Obtained device token: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
