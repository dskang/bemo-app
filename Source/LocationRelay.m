//
//  LocationRelay.m
//  Lumo
//
//  Created by Lumo on 4/13/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "LocationRelay.h"
#import "AFJSONRequestOperation.h"
#import "LumoAppDelegate.h"

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
#ifdef DEBUG
        NSLog(@"self: latitude %+.6f, longitude %+.6f\n",
              self.currentLocation.coordinate.latitude,
              self.currentLocation.coordinate.longitude);
#endif
        [self pushLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Required"
                                                        message:@"Please enable Location Services for Lumo in Settings"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        // End current connection
        [CallManager endConnection];
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
 * Start fetching partner location
 ******************************************************************************/
- (void)startPartnerUpdates {
    self.partnerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:PARTNER_LOC_POLL_INTERVAL target:self selector:@selector(pollForLocation) userInfo:nil repeats:YES];
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:LUMO_SESSION_TOKEN];
    NSString *url = [NSString stringWithFormat:@"%@/location/update", BASE_URL];
    NSNumber *latitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          deviceType, @"device",
                          latitude, @"latitude",
                          longitude, @"longitude",
                          sessionToken, @"token", nil];
    [LumoRequest postRequestToURL:url withDict:dict successNotification:LOC_PUSHED];
}

/******************************************************************************
 * Poll for partner location from server
 * 
 * Sets notifications:
 * PARTNER_LOC_UPDATED for successful location retrieval
 * "waiting" for a pending request
 * DISCONNECTED for failure (by timeout or disconnect)
 * "receive call" if there is already a pending call incoming
 ******************************************************************************/
- (void)pollForLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *sessionToken = [defaults objectForKey:LUMO_SESSION_TOKEN];
    NSString *partnerUrl = [NSString stringWithFormat:@"%@/call/%@/poll?token=%@", BASE_URL, [myAppDelegate.callManager.partnerInfo valueForKey:@"id"], sessionToken];
    NSURL *url = [NSURL URLWithString:partnerUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSString *status = [JSON valueForKeyPath:@"status"];
        
        if ([status isEqualToString:@"success"]) {
            // Announce that connection was established if trying to connect
            if ([myAppDelegate.appState isEqualToString:CONNECTING_STATE]) {
#ifdef DEBUG
                NSLog(@"Notification: %@", CONN_ESTABLISHED);
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:CONN_ESTABLISHED object:self];
            }

            // Save partner's location if it's not (0,0)
            // (0, 0) means that partner has not yet sent their real location or they have not moved for a while, both for which the correct behavior would be to not update partner's location
            CLLocationDegrees lat = [[JSON valueForKeyPath:@"data.latitude"] doubleValue];
            CLLocationDegrees lon = [[JSON valueForKeyPath:@"data.longitude"] doubleValue];
            if (!(lat == 0.0 && lon == 0.0)) {
                self.partnerLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
#ifdef DEBUG
                NSLog(@"partner: latitude %+.6f, longitude %+.6f\n",
                      self.partnerLocation.coordinate.latitude,
                      self.partnerLocation.coordinate.longitude);
#endif
#ifdef DEBUG
                NSLog(@"Notification: %@", PARTNER_LOC_UPDATED);
#endif
                [[NSNotificationCenter defaultCenter] postNotificationName:PARTNER_LOC_UPDATED object:self];
            }
        } else if ([status isEqualToString:@"failure"]) {
            NSString* error = [JSON valueForKeyPath:@"error"];
#ifdef DEBUG
            NSLog(@"Error Notification: %@", error);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:error object:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REQUEST_FAILED object:self];
    }];
    [operation start];
}

@end
