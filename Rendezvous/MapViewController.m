//
//  mapVC.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MapViewController.h"
#import "Pin.h"
#import "LocationRelay.h"

@interface MapViewController ()
@property (strong, nonatomic) Pin *contactPin;
@property (strong, nonatomic) LocationRelay *locationRelay;
@property (strong, nonatomic) NSTimer *partnerTimer;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
/* @synthesize pinsTimer;
 @synthesize viewTimer; */
@synthesize contactPin = _contactPin;
@synthesize locationRelay = _locationRelay;
@synthesize partnerTimer = _partnerTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startUpdating];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
    [self stopUpdating];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    
    /*_pinsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLocations) userInfo:nil repeats:YES];*/
    /* This bit of code auto-recenters. Currently de-timing this doesn't work.
     _viewTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recenter:) userInfo:self repeats:YES];
     */
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    
    
    /*[_pinsTimer invalidate];
     _pinsTimer = nil;
     [_viewTimer invalidate];
     _viewTimer = nil; */
}

- (Pin *)contactPin {
    if (!_contactPin) {
        _contactPin = [[Pin alloc] init];
        // Put pin on map
        [self.mapView addAnnotation:_contactPin];
    }
    return _contactPin;
}

- (LocationRelay *)locationRelay {
    if (!_locationRelay) {
        _locationRelay = [[LocationRelay alloc] init];
    }
    return _locationRelay;
}

- (void)updatePartnerLocationOnMap {
    // Show partner's location on map
    self.contactPin.coordinate = self.locationRelay.partnerLocation.coordinate;
    NSLog(@"partner: latitude %+.6f, longitude %+.6f\n",
          self.contactPin.coordinate.latitude,
          self.contactPin.coordinate.longitude);
}

- (void)startPartnerUpdatesOnMap {
    self.partnerTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updatePartnerLocationOnMap) userInfo:nil repeats:YES];
}

- (void)stopPartnerUpdatesOnMap {
    [self.partnerTimer invalidate];
}

- (void)startUpdating {
    NSLog(@"Start updating.");
    [self.locationRelay startSelfUpdates];
    [self.locationRelay startPartnerUpdates];
    [self startPartnerUpdatesOnMap];
}

- (void)stopUpdating {
    NSLog(@"Stop updating.");
    // [self.locationTracker stopSelfUpdates];
    [self.locationRelay stopPartnerUpdates];
    [self stopPartnerUpdatesOnMap];
}

- (IBAction)identityChanged:(UISegmentedControl *)sender {
    self.locationRelay.user = sender.selectedSegmentIndex;
    [self.locationRelay sendLocationToServer];
}
- (IBAction)endRendezvous:(id)sender {
    [self stopUpdating];
    [self dismissModalViewControllerAnimated:YES];
}

// This is called each time an annotation is added to the map
- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* contactPinID = @"contactPin";
    //static NSString* myPinID = @"myPin";
    MKPinAnnotationView* annotView = nil;
    
    // This code for the contact pin
    if ([annotation isKindOfClass:[Pin class]]) {
        annotView = (MKPinAnnotationView*) [_mapView dequeueReusableAnnotationViewWithIdentifier:contactPinID];
        if (annotView == nil) annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:contactPinID];
        else annotView.annotation = annotation;
    }
    
    if (annotView) {
        annotView.enabled = YES;
        annotView.canShowCallout = YES;
        return annotView;
    }
    
    return nil;
}

// Method called on press of recenter button
// See: http://stackoverflow.com/questions/1336370/positioning-mkmapview-to-show-multiple-annotations-at-once

- (IBAction)recenter:(id)sender {
    CLLocation *currentLocation = self.locationRelay.currentLocation;
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    
    southWest.latitude = MIN(currentLocation.coordinate.latitude, self.contactPin.coordinate.latitude);
    southWest.longitude = MIN(currentLocation.coordinate.longitude, self.contactPin.coordinate.longitude);
    
    northEast.latitude = MAX(currentLocation.coordinate.latitude, self.contactPin.coordinate.latitude);
    northEast.longitude = MAX(currentLocation.coordinate.longitude, self.contactPin.coordinate.longitude);
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
    
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    MKCoordinateRegion region;
    region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
    region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
    region.span.latitudeDelta = meters / 111319.5; // WOAH MAGIC!
    region.span.longitudeDelta = 0.0;
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
