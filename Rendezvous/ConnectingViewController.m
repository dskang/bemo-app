//
//  ConnectingViewController.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/27/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ConnectingViewController.h"
#import "RendezvousAppDelegate.h"

@interface ConnectingViewController ()
@property (weak, nonatomic) IBOutlet UILabel* contactName;
@property (strong, nonatomic) NSTimer* timeoutTimer;

@end

@implementation ConnectingViewController
@synthesize contactName;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.contactName.text = [myAppDelegate.contactFBinfo objectForKey:@"name"];
    
    self.timeoutTimer = [[NSTimer alloc] init];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(gotoMapView) userInfo:nil repeats:NO];
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
