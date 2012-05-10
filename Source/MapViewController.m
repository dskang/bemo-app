//
//  MapViewController.m
//  Lumo
//
//  Created by Lumo on 4/10/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "MapViewController.h"
#import "Pin.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"
#import "CallManager.h"

@interface MapViewController ()
@property (nonatomic, strong) Pin *contactPin;
@property (nonatomic, strong) NSTimer *partnerTimer;
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:(BOOL)animated];
    myAppDelegate.appState = MAP_STATE;
    [self startUpdating];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:(BOOL)animated];
    [self stopUpdating];
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
    CLLocation *partnerLocation = myAppDelegate.locationRelay.partnerLocation;
    // (0, 0) means that partner has not yet sent their real location or they have not moved for a while, both for which the correct behavior would be to not move the pin
    if (partnerLocation.coordinate.latitude == 0.0 && partnerLocation.coordinate.longitude == 0.0) return;
    // Show partner's location on map
    self.contactPin.coordinate = partnerLocation.coordinate;
}

- (void)startUpdating {
    NSLog(@"Start updating map view.");
    // Listen for partner updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerLocationOnMap) name:PARTNER_LOC_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endConnection) name:DISCONNECTED object:nil];

    [myAppDelegate.locationRelay startSelfUpdates];
    [myAppDelegate.locationRelay startPartnerUpdates];
}

- (void)stopUpdating {
    NSLog(@"Stop updating map view.");
    // Stop listening for partner updates
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [myAppDelegate.locationRelay stopSelfUpdates];
    [myAppDelegate.locationRelay stopPartnerUpdates];
}

- (void)endConnection {
    NSLog(@"Segue: Map -> Contacts");
    [self performSegueWithIdentifier:@"mapShowContacts" sender:nil];
}

- (IBAction)endConnectionButton:(id)sender {
    [CallManager endConnection];
    [self endConnection];
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
        annotView.image=[UIImage imageNamed:@"pin.png"];
        return annotView;
    }
    return nil;
}

// Method called on press of recenter button
// See: http://stackoverflow.com/questions/1336370/positioning-mkmapview-to-show-multiple-annotations-at-once

- (IBAction)recenter:(id)sender {
    // Return if we don't have a location for partner
    CLLocation *partnerLocation = myAppDelegate.locationRelay.partnerLocation;
    if (partnerLocation.coordinate.latitude == 0.0 && partnerLocation.coordinate.longitude == 0.0) return;

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
