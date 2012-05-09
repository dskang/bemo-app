//
//  MapViewController.h
//  Lumo
//
//  Created by Lumo on 4/10/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet MKMapView* mapView;

- (IBAction)recenter:(id)sender;

@end
