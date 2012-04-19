//
//  mapVC.h
//  Rendezvous
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface mapVC : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;
/*@property (weak, nonatomic) NSTimer* _pinsTimer;
@property (weak, nonatomic) NSTimer* _viewTimer; */

- (IBAction)recenter:(id)sender;

@end
