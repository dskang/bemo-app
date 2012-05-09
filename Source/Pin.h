//
//  Pin.h
//  Lumo
//
//  Created by Harvest Zhang on 4/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pin : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate;

@end
