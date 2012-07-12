//
//  LocationRelay.h
//  Bemo
//
//  Created by Lumo Labs on 4/13/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
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

- (void)pushLocation;
- (void)pollForLocation;

@end
