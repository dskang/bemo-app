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
#import <QuartzCore/QuartzCore.h>

@interface ReceivingViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *contactName;
@property (weak, nonatomic) IBOutlet UIImageView *partnerImage;
@property (nonatomic, strong) NSTimer *partnerUpdateTimer;
@end

@implementation ReceivingViewController
@synthesize contactName = _contactName;
@synthesize partnerImage = _partnerImage;
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
    // Set black border around partner image
    self.partnerImage.layer.borderColor = [[UIColor blackColor] CGColor];
    self.partnerImage.layer.borderWidth = 2.0;
    // Resize border for image
    CGRect frame = [self getFrameSizeForImage:self.partnerImage.image inImageView:self.partnerImage];
    CGRect imageViewFrame = CGRectMake(self.partnerImage.frame.origin.x + frame.origin.x, self.partnerImage.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
    self.partnerImage.frame = imageViewFrame;
}

- (void)viewDidUnload {
    [self setPartnerImage:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.contactName.title = [myAppDelegate.callManager.partnerInfo objectForKey:@"name"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopConnecting) name:DISCONNECTED object:nil];

    if ([myAppDelegate.callManager.partnerInfo valueForKey:@"image"]) {
        [self updatePartnerImage];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePartnerImage) name:PARTNER_IMAGE_UPDATED object:nil];
    }

    // Poll to check if partner has disconnected
    self.partnerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:myAppDelegate.locationRelay selector:@selector(pollForLocation) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.partnerUpdateTimer invalidate];
}

- (void)updatePartnerImage {
    UIImage *image = [myAppDelegate.callManager.partnerInfo valueForKey:@"image"];
    self.partnerImage.image = image;
    // Resize border for image
    CGRect frame = [self getFrameSizeForImage:self.partnerImage.image inImageView:self.partnerImage];
    CGRect imageViewFrame = CGRectMake(self.partnerImage.frame.origin.x + frame.origin.x, self.partnerImage.frame.origin.y + frame.origin.y, frame.size.width, frame.size.height);
    self.partnerImage.frame = imageViewFrame;
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
