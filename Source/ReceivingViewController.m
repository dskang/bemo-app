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
@property (weak, nonatomic) IBOutlet UINavigationBar *titleBar;
@end

@implementation ReceivingViewController
@synthesize titleBar = _titleBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopConnecting) name:DISCONNECTED object:nil];
}

- (void)viewDidUnload {
    [self setTitleBar:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:DISCONNECTED];
}

- (void)stopConnecting {
    [CallManager endConnection];
    [self performSegueWithIdentifier:@"receiverGotoContacts" sender:nil];
}

- (IBAction)acceptButton {
    [self performSegueWithIdentifier:@"receiverGotoMapView" sender:nil];
}

- (IBAction)declineButton {
    [self stopConnecting];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
