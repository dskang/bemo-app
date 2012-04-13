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

@interface mapVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* _mapView;
@property (weak, nonatomic) NSTimer* _pinsTimer;
@property (weak, nonatomic) NSTimer* _viewTimer;
@property (nonatomic, retain) CLLocationManager* _locationManager;
@property (nonatomic) CLLocationCoordinate2D _myLocation;
@property (nonatomic) CLLocationCoordinate2D _contactLocation;

- (IBAction)recenter:(id)sender;

@end
