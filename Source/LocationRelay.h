//
//  LocationRelay.h
//  Lumo
//
//  Created by Dan Kang on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationRelay : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *partnerLocation;

- (void)pushLocation;

- (void)startSelfUpdates;
- (void)stopSelfUpdates;

- (void)startPartnerUpdates;
- (void)stopPartnerUpdates;

// These interact with the server. They all set notifications.
- (void)getFriends;
- (void)pushLocation;
- (void)pollForLocation;

@end
