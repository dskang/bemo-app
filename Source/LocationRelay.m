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
 * Push user's location whenever we get an update
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
              self.currentLocation.coordinate.latitude,
              self.currentLocation.coordinate.longitude);
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
 * Start fetching partner location every 3 seconds
 ******************************************************************************/
- (void)startPartnerUpdates {
    self.partnerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pollForLocation) userInfo:nil repeats:YES];
}

/******************************************************************************
 * Stop fetching partner location
 ******************************************************************************/
- (void)stopPartnerUpdates {
    [self.partnerUpdateTimer invalidate];
}

/******************************************************************************
 * Push location to server
 *
 * Sets notifications:
 * LOC_PUSHED upon successful push to server
 ******************************************************************************/
- (void)pushLocation {
    NSString *url = [NSString stringWithFormat:@"%@/location/update", BASE_URL];
    NSNumber *latitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"iphone", @"device",
                          latitude, @"latitude",
                          longitude, @"longitude",
                          myAppDelegate.sessionToken, @"token", nil];
    [LumoRequest postRequestToURL:url withDict:dict successNotification:LOC_PUSHED];
}

/******************************************************************************
 * Poll for partner location from server
 * 
 * Sets notifications:
 * PARTNER_LOC_UPDATED for successful location retrieval
 * "waiting" for a pending request
 * "disconnected" for failure (by timeout or disconnect)
 * "receive call" if there is already a pending call incoming
 ******************************************************************************/
- (void)pollForLocation {
    NSString *partnerUrl;
    partnerUrl = [NSString stringWithFormat:@"%@/call/%@/poll?token=%@", BASE_URL, [myAppDelegate.callManager.partnerInfo valueForKey:@"id"], myAppDelegate.sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            // Save partner's location
            CLLocationDegrees lat = [[JSON valueForKeyPath:@"data.latitude"] doubleValue];
            CLLocationDegrees lon = [[JSON valueForKeyPath:@"data.longitude"] doubleValue];
            self.partnerLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            NSLog(@"partner: latitude %+.6f, longitude %+.6f\n",
                  self.partnerLocation.coordinate.latitude,
                  self.partnerLocation.coordinate.longitude);

            [[NSNotificationCenter defaultCenter] postNotificationName:PARTNER_LOC_UPDATED object:self];
        } 
        
        else if ([status isEqualToString:@"failure"]) {
            NSString* error = [JSON valueForKeyPath:@"error"];
            if ([error isEqualToString:@"invalid"]) 
                NSLog(@"LocationRelay.m | pollForLocation(): invalid target_id.");
            [[NSNotificationCenter defaultCenter] postNotificationName:error object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self];
    }];
    [operation start];
}

@end
