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
#import <QuartzCore/QuartzCore.h>

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
    // Set black border around partner image
    self.partnerImage.layer.borderColor = [[UIColor blackColor] CGColor];
    self.partnerImage.layer.borderWidth = 2.0;
    // Resize border for image
    CGRect frame = [self getFrameSizeForImage:self.partnerImage.image inImageView:self.partnerImage];
    CGRect imageViewFrame = CGRectMake(self.partnerImage.frame.origin.x + frame.origin.x, self.partnerImage.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
    self.partnerImage.frame = imageViewFrame;

    // Set timeLeft from defaults (TODO - temporarily hardcoded)
    self.timeLeft = 60;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myAppDelegate.appState = CONNECTING_STATE;

    self.contactName.title = [myAppDelegate.callManager.partnerInfo objectForKey:@"name"];
    self.connectionStatus.text = @"Sending Request";

    // Set notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMapView) name:PARTNER_LOC_UPDATED object:nil];  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopConnecting) name:DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startPolling) name:CONN_REQUESTED object:nil];
    
    if ([myAppDelegate.callManager.partnerInfo valueForKey:@"image"]) {
        [self updatePartnerImage];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerImage) name:PARTNER_IMAGE_UPDATED object:nil];
    }
    
    // Show receiving view if incoming call during outgoing call
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReceive) name:CALL_WAITING object:nil];

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
    UIImage *image = [myAppDelegate.callManager.partnerInfo valueForKey:@"image"];
    self.partnerImage.image = image;
    // Resize border for image
    CGRect frame = [self getFrameSizeForImage:self.partnerImage.image inImageView:self.partnerImage];
    CGRect imageViewFrame = CGRectMake(self.partnerImage.frame.origin.x + frame.origin.x, self.partnerImage.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
    self.partnerImage.frame = imageViewFrame;
}

- (void)pollLocation {
    NSLog(@"ConnectingViewController | pollLocation() polling.");
    [myAppDelegate.locationRelay pollForLocation];
}

- (void)showMapView {
    NSLog(@"Segue: Connecting -> Map");
    [self performSegueWithIdentifier:@"showMapView" sender:nil];
}

- (void)showReceive {
    NSLog(@"Segue: Connecting -> Receive");
    [self performSegueWithIdentifier:@"showReceive" sender:nil];
}

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

# pragma mark Partner Image

// Stack Overflow: http://stackoverflow.com/questions/9706874/borders-dont-adjust-to-aspect-fit/9707308#9707308
- (CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    
    float hfactor = image.size.width / imageView.frame.size.width;
    float vfactor = image.size.height / imageView.frame.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = image.size.width / factor;
    float newHeight = image.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (imageView.frame.size.width - newWidth) / 2;
    float topOffset = (imageView.frame.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}

@end
