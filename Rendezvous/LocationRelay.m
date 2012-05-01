//
//  LocationRelay.m
//  Rendezvous
//
//  Created by Dan Kang on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationRelay.h"
#import "AFJSONRequestOperation.h"
#import "RendezvousAppDelegate.h"

@interface LocationRelay()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *partnerUpdateTimer;
@end

@implementation LocationRelay
@synthesize currentLocation = _currentLocation;
@synthesize partnerLocation = _partnerLocation;
@synthesize locationManager = _locationManager;
@synthesize partnerUpdateTimer = _partnerUpdateTimer;
@synthesize user = _user;
@synthesize contact = _contact;

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

// Start receiving standard updates for location
- (void)startSelfUpdates
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

// Stop receiving standard updates for location
- (void)stopSelfUpdates {
    [self.locationManager stopUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // Only use update if it's from the last 15 seconds
    if (abs(howRecent) < 15.0)
    {
        self.currentLocation = newLocation;
        NSLog(@"self: latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        [self sendLocationToServer];
    }
}

- (void)loginToRendezvous {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceKey = [defaults objectForKey:@"deviceKey"];
    NSString *serviceKey = [defaults objectForKey:@"FBAccessTokenKey"];
    
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          deviceKey, @"device_token",
                          @"facebook", @"service",
                          serviceKey, @"service_token", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];        
    
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"http://mapperapi.herokuapp.com/login"];
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
            myAppDelegate.sessionToken = [JSON valueForKeyPath:@"data.token"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:self];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailure" object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailure" object:self];
    }];
    [operation start];
}

- (void)getFriends {
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"http://mapperapi.herokuapp.com/friends?token=%@", myAppDelegate.sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse* response, id JSON) {
        NSString* status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"success"]) {
            myAppDelegate.contactArray = [JSON objectForKey:@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFriendsSuccess" object:self]; 
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFriendsFailure" object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getFriendsFailure" object:self];
    }];
    [operation start];
}

// Send self location to server
- (void)sendLocationToServer {
    NSNumber *latitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
    // Convert data to JSON
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:latitude, @"latitude", longitude, @"longitude", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];       
    // Form POST request
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"http://mapper-app.herokuapp.com/user/%lld", self.user];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setHTTPMethod:@"POST"];
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mutableRequest setHTTPBody:data];
    // Push location to server
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:mutableRequest success:nil failure:nil];
    [operation start];
}

// Fetch partner location every 2 seconds
- (void)startPartnerUpdates {
    self.partnerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fetchPartnerLocation) userInfo:nil repeats:YES];
}

// Stop fetching partner location
- (void)stopPartnerUpdates {
    [self.partnerUpdateTimer invalidate];
}

// Fetch partner location from server
- (void)fetchPartnerLocation {
    
    /*
     // Fetch partner's location
     NSString *partnerUrl;
     partnerUrl = [NSString stringWithFormat:@"http://mapper-app.herokuapp.com/user/%lld", self.contact];
     NSURL *url = [NSURL URLWithString:partnerUrl];
     NSURLRequest *request = [NSURLRequest requestWithURL:url];
     
     AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
     id error = [JSON valueForKeyPath:@"error"];
     if (error) {
     NSLog(@"%@", error);
     } else {
     CLLocationDegrees latitude = [(NSNumber *)[JSON valueForKeyPath:@"latitude"] doubleValue];
     CLLocationDegrees longitude = [(NSNumber *)[JSON valueForKeyPath:@"longitude"] doubleValue];
     self.partnerLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
     }
     } failure:nil];
     [operation start];*/
}

@end
