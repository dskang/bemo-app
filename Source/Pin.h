//
//  Pin.h
//  Lumo
//
//  Created by Lumo on 4/11/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pin : NSObject <MKAnnotation> 

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (id)initWithLocation:(CLLocationCoordinate2D)coordinate;

@end
