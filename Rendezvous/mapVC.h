//
//  mapVC.h
//  Rendezvous
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface mapVC : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *_mapView;
- (IBAction)recenter:(id)sender;

@end
