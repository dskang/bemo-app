//
//  ConnectingViewController.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/27/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ConnectingViewController.h"
#import "RendezvousAppDelegate.h"
#import "LocationRelay.h"

@interface ConnectingViewController ()
@property (weak, nonatomic) IBOutlet UILabel* contactName;

@end

@implementation ConnectingViewController
@synthesize contactName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.contactName.text = [myAppDelegate.contactInfo objectForKey:@"name"];
}

- (void)viewDidUnload {
    [self setContactName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)gotoMapView {
    [self performSegueWithIdentifier:@"gotoMapView" sender:nil];
}

- (IBAction)cancelRendezvous {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
