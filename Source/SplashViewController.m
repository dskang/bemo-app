//
//  SplashViewController.m
//  Bemo
//
//  Created by Lumo Labs on 5/8/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "SplashViewController.h"
#import "BemoAppDelegate.h"

@implementation SplashViewController

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
    myAppDelegate.appState = IDLE_STATE;

    // Listen for received calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReceiveScreen) name:CONN_WAITING object:nil];
    
    // Listen for successful login, then get contacts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContactsScreen) name:GET_FRIENDS_SUCCESS object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showReceiveScreen {
    [self performSegueWithIdentifier:@"showReceive" sender:nil];
}

- (void)showContactsScreen {
    [self performSegueWithIdentifier:@"showContacts" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
