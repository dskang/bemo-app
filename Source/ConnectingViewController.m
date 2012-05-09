//
//  ConnectingViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 4/27/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ConnectingViewController.h"
#import "LocationRelay.h"
#import "LumoAppDelegate.h"

@interface ConnectingViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (strong, nonatomic) NSTimer *pollTimer;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (nonatomic) NSInteger timeLeft;
@end

@implementation ConnectingViewController
@synthesize titleBar = _titleBar;
@synthesize timeLeftLabel = _timeLeftLabel;
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
	self.titleBar.title = [myAppDelegate.callManager.partnerInfo objectForKey:@"name"];
    
    // Set notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMapView) name:PARTNER_LOC_UPDATED object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopConnecting) name:DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPolling) name:CONN_REQUESTED object:nil];
    
    // Request connection, which then starts polling
    [CallManager initiateConnection];
    
    // Set timeLeft from defaults (TODO - temporarily hardcoded)
    self.timeLeft = 60;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self.pollTimer invalidate];
    [self.countdownTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Called from timer
- (void)pollLocation {
    NSLog(@"ConnectingViewController | pollLocation() polling.");
    [myAppDelegate.locationRelay pollForLocation];
}

// Called from observer
- (void)showMapView {
    [self performSegueWithIdentifier:@"showMapView" sender:nil];
}

// Called from observer
- (void)startPolling {
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
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButton {
    [self stopConnecting];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
