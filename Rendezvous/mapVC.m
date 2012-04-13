//
//  mapVC.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "mapVC.h"
#import "rdvPin.h"

@interface mapVC ()

@end

@implementation mapVC
@synthesize _mapView;
@synthesize _pinsTimer;
@synthesize _viewTimer;
@synthesize _locationManager;
@synthesize _myLocation;
@synthesize _contactLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self plotContact]; // We're plotting the contact here (DEBUG)
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [self set_mapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    _pinsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLocations) userInfo:nil repeats:YES];
    _viewTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recenter:) userInfo:self repeats:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    [_pinsTimer invalidate];
    _pinsTimer = nil;
    [_viewTimer invalidate];
    _viewTimer = nil;
}

- (void)refreshLocations {
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            CLLocation* location = [_locationManager location];
            _myLocation = [location coordinate];
            [annotation setCoordinate:_myLocation];
        }
    }
}

// For now, this is dummy -- we need to fill this in for real later
- (void)plotContact {
    CLLocationCoordinate2D coord;
    coord.latitude = 37.787;
    coord.longitude = -122.419;
    rdvPin* newContact = [[rdvPin alloc] initID:@"Harvest Zhang" atCoord:coord];
    [_mapView addAnnotation:newContact];
}

// This is called each time an annotation is added to the map
- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* contactPinID = @"contactPin";
    static NSString* myPinID = @"myPin";
    MKPinAnnotationView* annotView = nil;
    
    // This code for the contact pin
    if ([annotation isKindOfClass:[rdvPin class]]) {
        annotView = (MKPinAnnotationView*) [_mapView dequeueReusableAnnotationViewWithIdentifier:contactPinID];
        if (annotView == nil) annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:contactPinID];
        else annotView.annotation = annotation;
    }
    
    // This code for the user's own location pin
    else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        annotView = (MKPinAnnotationView*) [_mapView dequeueReusableAnnotationViewWithIdentifier:myPinID];
        if (annotView == nil) annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myPinID];
        else annotView.annotation = annotation;
        annotView.pinColor = MKPinAnnotationColorGreen;
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
    MKMapRect regionToDisplay = [self mapRectForAnnotations:_mapView.annotations];
    if (!MKMapRectIsNull(regionToDisplay))
        [_mapView setRegion:MKCoordinateRegionForMapRect(regionToDisplay) animated:YES];
}

- (MKMapRect) mapRectForAnnotations:(NSArray*)annotationsArray
{
    MKMapRect mapRect = MKMapRectNull;
    
    //annotations is an array with all the annotations I want to display on the map
    for (id<MKAnnotation> annotation in annotationsArray) { 
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        
        if (MKMapRectIsNull(mapRect)) 
        {
            mapRect = pointRect;
        } else 
        {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    return mapRect;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
