//
//  SplashViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 5/8/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "SplashViewController.h"
#import "LumoAppDelegate.h"

@interface SplashViewController ()
@property (strong, nonatomic) NSTimer *splashTimer;
@end

@implementation SplashViewController
@synthesize splashTimer = _splashTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Listen for received calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReceiveScreen) name:CALL_WAITING object:nil];
    
    // Listen for successful login, then get contacts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContactsScreen) name:GET_FRIENDS_SUCCESS object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.splashTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showReceiveScreen {
    NSLog(@"Segue: Splash -> Receive");
    [self performSegueWithIdentifier:@"showReceive" sender:nil];
}

- (void)showContactsScreen {
    NSLog(@"Segue: Splash -> Contacts");
    [self performSegueWithIdentifier:@"showContacts" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
