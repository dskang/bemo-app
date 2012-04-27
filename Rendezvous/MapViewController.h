//
//  MapViewController.h
//  Rendezvous
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView* mapView;

- (IBAction)recenter:(id)sender;
- (IBAction)endRendezvous:(id)sender;

@end
