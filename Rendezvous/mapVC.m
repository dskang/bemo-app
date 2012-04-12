//
//  mapVC.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/10/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "mapVC.h"
#import "contactDisplay.h"

@interface mapVC ()

@end

@implementation mapVC
@synthesize _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// For now, this is dummy -- we need to fill this in for real later
- (void)plotContact {
    // If we want to get rid of all existing annotations...
    for (id<MKAnnotation> annotation in _mapView.annotations)
        [_mapView removeAnnotation:annotation];
    
    CLLocationCoordinate2D coord;
    coord.latitude = 37.787;
    coord.longitude = -122.419;
    contactDisplay* newContact = [[contactDisplay alloc] initID:@"Harvest Zhang" atCoord:coord];
    [_mapView addAnnotation:newContact];
}

// This is called each time an annotation is added to the map
- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* identifier = @"ContactLocation";
    
    if ([annotation isKindOfClass:[contactDisplay class]]) {
        MKPinAnnotationView* annotView = (MKPinAnnotationView*) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotView == nil) annotView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        else annotView.annotation = annotation;
        
        annotView.enabled = YES;
        annotView.canShowCallout = YES;
        return annotView;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self set_mapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Method called on button-press of lower left
- (IBAction)recenter:(id)sender {
    [self plotContact];
}
@end
