//
//  LumoAppDelegate.m
//  Lumo
//
//  Created by Lumo on 4/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "LumoAppDelegate.h"
#import "ReceivingViewController.h"

@implementation LumoAppDelegate

@synthesize window = _window;
@synthesize appState = _appState;
@synthesize auth = _auth;
@synthesize locationRelay = _locationRelay;
@synthesize callManager = _callManager;
@synthesize contactsManager = _contactsManager;

/******************************************************************************
 * Getters
 ******************************************************************************/
- (NSString *)appState {
    if (!_appState) {
        _appState = IDLE_STATE;
    }
    return _appState;
}
- (LocationRelay *)locationRelay {
    if (!_locationRelay) {
        _locationRelay = [[LocationRelay alloc] init];
    }
    return _locationRelay;
}

- (CallManager *)callManager {
    if (!_callManager) {
        _callManager = [[CallManager alloc] init];
    }
    return _callManager;
}

- (ContactsManager *)contactsManager {
    if (!_contactsManager) {
        _contactsManager = [[ContactsManager alloc] init];
    }
    return _contactsManager;
}

- (Authentication *)auth {
    if (!_auth) {
        _auth = [[Authentication alloc] init];
    }
    return _auth;
}

/******************************************************************************
 * Lumo
 ******************************************************************************/
- (void)getLumoFriends {
    [ContactsManager getFriends];
}

- (void)requestFailure {
#ifdef DEBUG
    NSLog(@"Request failed: request operation was unsuccessful or server returned non-JSON data.");
#endif
}

- (void)authFailure {
#ifdef DEBUG
    NSLog(@"Auth failed.");
#endif
    self.auth.loginRequired = YES;
    [self.auth authenticate];
}

/******************************************************************************
 * Device ID generation
 ******************************************************************************/
- (void)generateDeviceKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceKey = [defaults objectForKey:DEVICE_KEY];
    if (!deviceKey) {
        CFUUIDRef newDeviceKey = CFUUIDCreate(NULL);
        deviceKey = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, newDeviceKey);
        [defaults setObject:deviceKey forKey:DEVICE_KEY];
        CFRelease(newDeviceKey);
#ifdef DEBUG
        NSLog(@"Generated new device key.");
#endif

        // Indicate that user's info changed
        self.auth.loginRequired = YES;
    }
#ifdef DEBUG
    NSLog(@"Device key: %@", deviceKey);
#endif
}

/******************************************************************************
 * Application states
 ******************************************************************************/
// Application launched from a non-running state
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

#ifdef TESTFLIGHT
    // NOTE: This is deprecated functionality, but we need it for TestFlight
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"bfbaf3f6b1f916491e638d2777f7bf58_ODk2NDkyMDEyLTA1LTEyIDA4OjQyOjE0LjIwNTkyOQ"];
#endif

    // Check if app was opened from a push notification
    if (launchOptions)
	{
		NSDictionary* pushNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (pushNotification)
		{
            [self application:application didReceiveRemoteNotification:pushNotification];
		}
    }

    // Generate device ID if necessary
    [self generateDeviceKey];
    
    // Create notification observer for server failure or auth failure
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFailure) name:REQUEST_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authFailure) name:AUTH_FAILED object:nil];
    
    // Create notification observer for app flow
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSessionToken:) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLumoFriends) name:LOGIN_SUCCESS object:nil];
    
    // Register for push notification
#if !(TARGET_IPHONE_SIMULATOR)
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#else
    [self.auth authenticate];
#endif

    return YES;
}

// Called when notifcation comes in while app is active or suspended
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)pushNotification
{
    NSString *key = [pushNotification valueForKeyPath:@"aps.alert.loc-key"];
#ifdef DEBUG
    NSLog(@"Received push notification: %@", key);
#endif
    if ([key isEqualToString:@"INCOMING_CALL"]) {
        NSArray *args = [pushNotification valueForKeyPath:@"aps.alert.loc-args"];
        NSString *sourceName = [args objectAtIndex:0];
        NSString *sourceID = [pushNotification valueForKey:@"id"];
        NSDictionary *sourceService = [pushNotification valueForKey:@"service"];

        if (![self.appState isEqualToString:IDLE_STATE]) {
            BOOL incomingCallFromCurrentPartner = [sourceID isEqualToString:[self.callManager.partnerInfo valueForKey:@"id"]];
            if (!incomingCallFromCurrentPartner) {
                [CallManager endConnectionWithID:sourceID];
                [self showMissedRequestAlertFromName:sourceName];
            }
            return;
        }

        // Save contact info
        self.callManager.partnerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:sourceID, @"id", sourceName, @"name", sourceService, @"service", nil];
        [self.contactsManager getPartnerImage];

        // Poll to see if call is still going on
        [self.locationRelay pollForLocation];
    } else if ([key isEqualToString:@"MISSED_CALL"]) {
        NSArray *args = [pushNotification valueForKeyPath:@"aps.alert.loc-args"];
        NSString *sourceName = [args objectAtIndex:0];
        if (![self.appState isEqualToString:IDLE_STATE]) {
            [self showMissedRequestAlertFromName:sourceName];
        }
    }
}

- (void)showMissedRequestAlertFromName:(NSString *)name {
    NSString *message = [NSString stringWithFormat:@"You missed a Lumo request from %@", name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missed Lumo Request"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)saveSessionToken:(NSNotification *)notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken;
    if ([notification userInfo]) {
        sessionToken = [[notification userInfo] valueForKeyPath:@"data.token"];
        [defaults setObject:sessionToken forKey:LUMO_SESSION_TOKEN];
    } else {
        sessionToken = [defaults objectForKey:LUMO_SESSION_TOKEN];
    }
#ifdef DEBUG
    NSLog(@"Session token: %@", sessionToken);
#endif
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

    // Extend the Facebook access token
    [self.auth.facebook extendAccessTokenIfNeeded];

    // Clear notifications from Notification Center
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/******************************************************************************
 * Facebook
 ******************************************************************************/
// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.auth.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.auth.facebook handleOpenURL:url]; 
}

/******************************************************************************
 * Push notifications
 ******************************************************************************/
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] 
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *storedToken = [defaults objectForKey:DEVICE_TOKEN];
    if (![token isEqualToString:storedToken]) {
        [defaults setObject:token forKey:DEVICE_TOKEN];
#ifdef DEBUG
        NSLog(@"Generated new device token.");
#endif
        // Indicate that user's info changed
        self.auth.loginRequired = YES;
    }

#ifdef DEBUG
    NSLog(@"Device token: %@", deviceToken);
#endif

    // Authenticate user
    [self.auth authenticate];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
#ifdef DEBUG
	NSLog(@"Failed to get token, error: %@", error);
#endif
}

@end
