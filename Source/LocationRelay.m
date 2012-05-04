//
//  LocationRelay.m
//  Lumo
//
//  Created by Dan Kang on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationRelay.h"
#import "AFJSONRequestOperation.h"
#import "LumoAppDelegate.h"
// Used to check if using device or simulator
#import "TargetConditionals.h"

@interface LocationRelay()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *partnerUpdateTimer;
@end

@implementation LocationRelay
@synthesize currentLocation = _currentLocation;
@synthesize partnerLocation = _partnerLocation;
@synthesize locationManager = _locationManager;
@synthesize partnerUpdateTimer = _partnerUpdateTimer;

/******************************************************************************
 * Make new CLLocationManager if one doesn't exist
 ******************************************************************************/
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

/******************************************************************************
 * Delegate method from the CLLocationManagerDelegate protocol.
 ******************************************************************************/
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // Only use update if it's from the last 15 seconds
    if (abs(howRecent) < 15.0)
    {
        self.currentLocation = newLocation;
        NSLog(@"self: latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        [self pushLocation];
    }
}

/******************************************************************************
 * Start updating own location
 ******************************************************************************/
- (void)startSelfUpdates {
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

/******************************************************************************
 * Stop updating own location
 ******************************************************************************/
- (void)stopSelfUpdates {
    [self.locationManager stopUpdatingLocation];
}

/******************************************************************************
 * Start fetching partner location every 2 seconds
 ******************************************************************************/
- (void)startPartnerUpdates {
    self.partnerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(pollForLocation) userInfo:nil repeats:YES];
}

/******************************************************************************
 * Stop fetching partner location
 ******************************************************************************/
- (void)stopPartnerUpdates {
    [self.partnerUpdateTimer invalidate];
}

/******************************************************************************
 * Login to the Rendezvous server
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

/******************************************************************************
 * Get FB friends who use the app, save to app delegate
 *
 * Sets notifications:
 * "getFriendsSuccess" for successful friend retrieval
 ******************************************************************************/
- (void)getFriends {
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/friends?token=%@", BASE_URL, myAppDelegate.sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"success"]) {
            myAppDelegate.contactArray = [JSON objectForKey:@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFriendsSuccess" object:self]; 
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * Initiate connection to a contact
 *
 * Sets notifications:
 * "connRequested" for successful requesting of a call
 * "auth" upon authentication failure
 ******************************************************************************/
- (void)initiateConnection {
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          @"facebook", @"service",
                          myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/init", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connRequested" object:self];
            NSLog(@"LocationRelay.m | initiateConnection(): init request succeeded!");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"auth" object:self];  
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * Receive connection from a contact
 * (Push notification MUST establish caller ID!)
 *
 * Sets notifications:
 * "connReceived" for successful reception of a call
 * "disconnected" if the caller disconnected
 * "auth" upon authentication failure
 ******************************************************************************/
- (void)receiveConnection {
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/receive", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connReceived" object:self];
            NSLog(@"LocationRelay.m | receiveConnection(): Connection successfully received!");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[JSON valueForKeyPath:@"error"] object:self];  
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * End an active connection
 *
 * Sets notifications:
 * "connEnded" for successful ending of a connection
 * "auth" upon authentication failure
 ******************************************************************************/
- (void)endConnection {
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/end", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"]];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    
    // Send request
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:^(NSURLRequest* request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connEnded" object:self];
            NSLog(@"LocationRelay.m | endConnection(): Connection successfully ended!");
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[JSON valueForKeyPath:@"error"] object:self];  
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * Push location to server
 *
 * Sets notifications:
 * "locationPushed" upon successful push to server (Not used as callback)
 * "auth" upon authentication failure
 ******************************************************************************/
- (void)pushLocation {
    NSNumber *latitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          latitude, @"latitude",
                          longitude, @"longitude",
                          myAppDelegate.sessionToken, @"token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil]; 
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/location/update", BASE_URL];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"locationPushed" object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"auth" object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

/******************************************************************************
 * Poll for partner location from server
 * 
 * Sets notifications:
 * "connected" for successful location retrieval
 * "waiting" for a pending request
 * "disconnected" for failure (by timeout or disconnect)
 * "receive call" if there is already a pending call incoming
 ******************************************************************************/
- (void)pollForLocation {
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/poll?token=%@", BASE_URL, [myAppDelegate.contactInfo valueForKey:@"id"], myAppDelegate.sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            NSLog(@"pollForLocation(): connection established!"); // HEFFALUMPS
            CLLocationDegrees lat = [[JSON valueForKeyPath:@"data.latitude"] doubleValue];
            CLLocationDegrees lon = [[JSON valueForKeyPath:@"data.longitude"] doubleValue];
            self.partnerLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connected" object:self];
        } 
        
        else if ([status isEqualToString:@"failure"]) {
            NSString* error = [JSON valueForKeyPath:@"error"];
            if ([error isEqualToString:@"invalid"]) 
                NSLog(@"LocationRelay.m | pollForLocation(): invalid target_id.");
            [[NSNotificationCenter defaultCenter] postNotificationName:error object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"serverFailure" object:self];
    }];
    [operation start];
}

@end
