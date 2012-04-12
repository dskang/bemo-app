//
//  contactDisplay.h
//  Rendezvous
//
//  Created by Harvest Zhang on 4/11/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface contactDisplay : NSObject <MKAnnotation> {
    NSString* _devID;
    CLLocationCoordinate2D _coord;
}

@property (nonatomic, readonly, copy) NSString* subtitle;
@property (nonatomic, readonly, copy) NSString* title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initID:(NSString*)devID atCoord:(CLLocationCoordinate2D)coordinate;


@end
