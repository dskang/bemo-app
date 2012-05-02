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
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (strong, nonatomic) NSTimer *timeoutTimer;

@end

@implementation ConnectingViewController
@synthesize contactName = _contactName;
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

- (IBAction)cancelLumo {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
