//
//  ReceivingViewController.m
//  Lumo
//
//  Created by Lumo on 5/8/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "ReceivingViewController.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"

@interface ReceivingViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *contactName;
@property (nonatomic, strong) NSTimer *partnerUpdateTimer;
@end

@implementation ReceivingViewController
@synthesize contactName = _contactName;
@synthesize partnerUpdateTimer = _partnerUpdateTimer;

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
    [super viewWillAppear:animated];
    self.contactName.title = [myAppDelegate.callManager.partnerInfo objectForKey:@"name"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopConnecting) name:DISCONNECTED object:nil];
    // Poll to check if partner has disconnected
    self.partnerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:myAppDelegate.locationRelay selector:@selector(pollForLocation) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.partnerUpdateTimer invalidate];
}

- (void)stopConnecting {
    [CallManager endConnection];
    NSLog(@"Segue: Receive -> Contacts");
    [self performSegueWithIdentifier:@"receiverShowContacts" sender:nil];
}

- (IBAction)acceptButton {
    // Need to remove observer so that stopConnecting is not called if receive returns disconnected
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [CallManager receiveConnection];
    NSLog(@"Segue: Receive -> Map");
    [self performSegueWithIdentifier:@"receiverShowMapView" sender:nil];
}

- (IBAction)declineButton {
    [self stopConnecting];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
