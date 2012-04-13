//
//  rdvPin.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "rdvPin.h"

@implementation rdvPin

@synthesize subtitle;
@synthesize title = _devID;
@synthesize coordinate = _coord;

- (id)initID:(NSString*)devID atCoord:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _devID = [devID copy];
        _coord = coordinate;
    }
    return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coord = newCoordinate;
}

@end
