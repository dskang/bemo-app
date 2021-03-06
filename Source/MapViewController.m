//
//  MapViewController.m
//  Bemo
//
//  Created by Lumo Labs on 4/10/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "MapViewController.h"
#import "Pin.h"
#import "LocationRelay.h"
#import "BemoAppDelegate.h"
#import "CallManager.h"

@interface MapViewController ()
@property (nonatomic, weak) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) Pin *contactPin;
@property (nonatomic, strong) NSTimer *partnerTimer;
// Whether map has been initially centered between partner and self
@property (nonatomic, assign) BOOL initialCenter;
@property (nonatomic, assign) BOOL userOnMap;
@property (nonatomic, assign) BOOL partnerOnMap;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize contactPin = _contactPin;
@synthesize partnerTimer = _partnerTimer;
@synthesize initialCenter = _initialCenter;
@synthesize userOnMap = _userOnMap;
@synthesize partnerOnMap = _partnerOnMap;

- (Pin *)contactPin {
    if (!_contactPin) {
        _contactPin = [[Pin alloc] init];
        
        // Put pin on map
        [self.mapView addAnnotation:_contactPin];
    }
    return _contactPin;
}

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
    
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"MAP"];
#endif

#ifdef MIXPANEL
    [[MixpanelAPI sharedAPI] track:@"MAP"];
#endif

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerLocationOnMap) name:PARTNER_LOC_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateUserLocation) name:SELF_LOC_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnection) name:CONN_WAITING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected) name:DISCONNECTED object:nil];

    [myAppDelegate.locationRelay startSelfUpdates];
    [myAppDelegate.locationRelay startPartnerUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:(BOOL)animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [myAppDelegate.locationRelay stopSelfUpdates];
    [myAppDelegate.locationRelay stopPartnerUpdates];

    // Reset locations
    myAppDelegate.locationRelay.partnerLocation = nil;
    myAppDelegate.locationRelay.currentLocation = nil;
}

- (void)receiveConnection {
    [CallManager receiveConnection];
}

- (void)updatePartnerLocationOnMap {
    // Show partner's location on map
    self.contactPin.coordinate = myAppDelegate.locationRelay.partnerLocation.coordinate;
    [self didUpdatePartnerLocation];
}

- (void)disconnected {
    NSString *message = [NSString stringWithFormat:@"%@ ended the connection", [myAppDelegate.callManager.partnerInfo valueForKey:@"name"]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bemo Ended"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self performSegueWithIdentifier:@"mapShowContacts" sender:nil];
}

- (IBAction)endConnectionButton:(id)sender {
    [CallManager endConnection];
    [self performSegueWithIdentifier:@"mapShowContacts" sender:nil];
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
        annotView.image = [UIImage imageNamed:@"dot.png"];
        annotView.centerOffset = CGPointMake(-3,6);
        return annotView;
    }
    return nil;
}

// Method called on press of recenter button
// See: http://stackoverflow.com/questions/1336370/positioning-mkmapview-to-show-multiple-annotations-at-once

- (IBAction)recenter:(id)sender {
    CLLocation *partnerLocation = myAppDelegate.locationRelay.partnerLocation;
    CLLocation *currentLocation = myAppDelegate.locationRelay.currentLocation;
    if (currentLocation == nil || partnerLocation == nil) {
        return;
    }

    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    
    southWest.latitude = MIN(currentLocation.coordinate.latitude, partnerLocation.coordinate.latitude);
    southWest.longitude = MIN(currentLocation.coordinate.longitude, partnerLocation.coordinate.longitude);
    
    northEast.latitude = MAX(currentLocation.coordinate.latitude, partnerLocation.coordinate.latitude);
    northEast.longitude = MAX(currentLocation.coordinate.longitude, partnerLocation.coordinate.longitude);
    
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
    
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    
    MKCoordinateRegion region;
    region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
    region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
    region.span.latitudeDelta = (meters / 111319.5) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = 0.0;
    
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 * Recenter map when both user and partner first appear on map.
 */

-(void)didUpdatePartnerLocation {
    self.partnerOnMap = YES;

    // Center map when partner and self both initially appear on map
    if (!self.initialCenter && self.userOnMap && self.partnerOnMap) {
        [self recenter:nil];
        self.initialCenter = YES;
    }
}

- (void)didUpdateUserLocation {
    self.userOnMap = YES;

    // Center map when partner and self both initially appear on map
    if (!self.initialCenter && self.userOnMap && self.partnerOnMap) {
        [self recenter:nil];
        self.initialCenter = YES;
    }
}

@end
