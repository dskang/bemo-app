//
//  Pin.h
//  Bemo
//
//  Created by Lumo Labs on 4/11/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pin : NSObject <MKAnnotation> 

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate;

@end
