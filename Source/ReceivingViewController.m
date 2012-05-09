//
//  ReceivingViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 5/8/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ReceivingViewController.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"

@interface ReceivingViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *contactName;
@end

@implementation ReceivingViewController
@synthesize contactName = _contactName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contactName.title = [myAppDelegate.callManager.partnerInfo objectForKey:@"name"];
    // TODO: poll to make sure call has not been disconnected
}

- (void)viewDidUnload {
    [self setContactName:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopConnecting {
    [CallManager endConnection];
    [self performSegueWithIdentifier:@"receiverShowContacts" sender:nil];
}

- (IBAction)acceptButton {
    // Receive connection and let the map view deal with scenario in which partner disconnected
    [CallManager receiveConnection];
    [self performSegueWithIdentifier:@"receiverShowMapView" sender:nil];
}

- (IBAction)declineButton {
    [self stopConnecting];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
