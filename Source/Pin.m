//
//  Pin.m
//  Lumo
//
//  Created by Lumo on 4/11/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "Pin.h"
#import "LumoAppDelegate.h"
@interface Pin()

@end

@implementation Pin
@synthesize coordinate = _coordinate;
@synthesize title = _title;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
    }
    [self setTitle:@"Contact Name"];
    return self;
}

- (NSString *)subtitle {
    return nil;
}

- (NSString *)title {
    NSLog(@"%@", self.title);
    return self.title;
}

@end

