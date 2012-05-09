//
//  Pin.m
//  Lumo
//
//  Created by Harvest Zhang on 4/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "Pin.h"
@interface Pin()

@end

@implementation Pin
@synthesize coordinate = _coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
    }
    return self;
}
@end

