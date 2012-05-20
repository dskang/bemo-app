//
//  Pin.m
//  Lumo
//
//  Created by Lumo on 4/11/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "Pin.h"
#import "LumoAppDelegate.h"

@implementation Pin
@synthesize coordinate = _coordinate;
@synthesize title = _title;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if (!_title) {
        _title = [myAppDelegate.callManager.partnerInfo valueForKey:@"name"];
    }
    return _title;
}

@end

