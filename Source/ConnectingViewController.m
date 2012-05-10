//
//  ConnectingViewController.m
//  Lumo
//
//  Created by Lumo on 4/27/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "ConnectingViewController.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"

@interface ConnectingViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *contactName;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatus;
@property (weak, nonatomic) IBOutlet UIImageView *partnerImage;
@property (strong, nonatomic) NSTimer *pollTimer;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (nonatomic) NSInteger timeLeft;
@end

@implementation ConnectingViewController
@synthesize contactName = _contactName;
@synthesize timeLeftLabel = _timeLeftLabel;
@synthesize connectionStatus = _connectionStatus;
@synthesize partnerImage = _partnerImage;
@synthesize pollTimer = _pollTimer;
@synthesize countdownTimer = _timeoutTimer;
@synthesize timeLeft = _timeLeft;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set timeLeft from defaults (TODO - temporarily hardcoded)
    self.timeLeft = 60;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.contactName.title = [myAppDelegate.callManager.partnerInfo objectForKey:@"name"];
    self.connectionStatus.text = @"Sending Request";

    // Set notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMapView) name:PARTNER_LOC_UPDATED object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopConnecting) name:DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPolling) name:CONN_REQUESTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerImage) name:PARTNER_IMAGE_UPDATED object:nil];
    
    // Automatically receive a call from partner (occurs when two users call each other at the same time)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnection) name:CALL_WAITING object:nil];

    // Get partner's image
    [myAppDelegate.contactsManager getPartnerImage];

    // Request connection, which then starts polling
    [CallManager initiateConnection];
}

- (void)viewDidUnload {
    [self setConnectionStatus:nil];
    [self setPartnerImage:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pollTimer invalidate];
    [self.countdownTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updatePartnerImage {
    NSLog(@"updatePartnerImage called");
    UIImage *image = [myAppDelegate.callManager.partnerInfo valueForKey:@"image"];
    NSLog(@"%@", image);
    self.partnerImage.image = image;
}

// Called from timer
- (void)pollLocation {
    NSLog(@"ConnectingViewController | pollLocation() polling.");
    [myAppDelegate.locationRelay pollForLocation];
}

// Called from observer
- (void)showMapView {
    NSLog(@"Segue: Connecting -> Map");
    [self performSegueWithIdentifier:@"showMapView" sender:nil];
}

- (void)receiveConnection {
    [CallManager receiveConnection];
}

// Called from observer
- (void)startPolling {
    // Update connection status
    self.connectionStatus.text = @"Waiting for Response";

    // Poll for a connection every 3 seconds
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(pollLocation) userInfo:nil repeats:YES];
    
    // Start the countdown timer
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
}

- (void)countdown {
    if (self.timeLeft <= 0) [self stopConnecting];
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%02d:%02d", self.timeLeft/60, self.timeLeft%60];
    self.timeLeft--;
}

// Called from observer, cancel button, and countdown timeout
- (void)stopConnecting {
    [CallManager endConnection];
    NSLog(@"Segue: Connecting dismissed");
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButton {
    [self stopConnecting];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
