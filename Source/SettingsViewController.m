//
//  SettingsViewController.m
//  Lumo
//
//  Created by Lumo on 4/10/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISlider *timeToWait;
@property (weak, nonatomic) IBOutlet UILabel *waitingForResponseLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingSpinner;
@end

@implementation SettingsViewController
@synthesize timeToWait = _timeToWait;
@synthesize waitingForResponseLabel = _waitingForResponseLabel;
@synthesize waitingSpinner = _waitingSpinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setTimeToWait:nil];
    [self setWaitingForResponseLabel:nil];
    [self setWaitingSpinner:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
