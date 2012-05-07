//
//  MapViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "MapViewController.h"
#import "Pin.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"
#import "CallManager.h"

@interface MapViewController ()
@property (strong, nonatomic) Pin *contactPin;
@property (strong, nonatomic) NSTimer *partnerTimer;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize contactPin = _contactPin;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endConnection) name:@"disconnected" object:nil];
    [self startUpdating];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
    [self stopUpdating];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    [[NSNotificationCenter defaultCenter] removeObserver:@"disconnected"];
}

- (Pin *)contactPin {
    if (!_contactPin) {
        _contactPin = [[Pin alloc] init];
        // Put pin on map
        [self.mapView addAnnotation:_contactPin];
    }
    return _contactPin;
}

- (void)updatePartnerLocationOnMap {
    // Show partner's location on map
    self.contactPin.coordinate = myAppDelegate.locationRelay.partnerLocation.coordinate;
}

- (void)startUpdating {
    NSLog(@"Start updating map view.");
    [myAppDelegate.locationRelay startSelfUpdates];
    [myAppDelegate.locationRelay startPartnerUpdates];
    // Listen for partner updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerLocationOnMap) name:PARTER_LOC_UPDATED object:nil];
}

- (void)stopUpdating {
    NSLog(@"Stop updating map view.");
    [myAppDelegate.locationRelay stopSelfUpdates];
    [myAppDelegate.locationRelay stopPartnerUpdates];
    // Stop listening for partner updates
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)endConnection {
    // FIXME: This shows connecting screen instead of contacts screen
    [self stopUpdating];
    [CallManager endConnection];
    [self performSegueWithIdentifier:@"endMapView" sender:nil];
}

// Called each time an annotation is added to the map
- (MKAnnotationView *)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *contactPinID = @"contactPin";
    MKPinAnnotationView *annotView = nil;
    
    if ([annotation isKindOfClass:[Pin class]]) {
        annotView = (MKPinAnnotationView*) [_mapView dequeueReusableAnnotationViewWithIdentifier:contactPinID];
        if (!annotView) {
            annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:contactPinID];   
        } else {
            annotView.annotation = annotation;   
        }
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
    CLLocation *currentLocation = myAppDelegate.locationRelay.currentLocation;
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
