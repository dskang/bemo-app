//
//  rdvSecondViewController.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "rendezvousVC.h"
#import "rdvFBContacts.h"

@interface rendezvousVC ()
@property (strong, nonatomic) NSArray* contacts;
@property (strong, nonatomic) NSArray* indices;
@property (strong, nonatomic) rdvFBContacts* FBContacts;
@end

@implementation rendezvousVC
@synthesize contacts = _contacts;
@synthesize indices = _indices;
@synthesize FBContacts = _FBContacts;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_FBContacts requestContacts];
    NSLog(@"requestContacts supposedly called.");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.textLabel.text = @"Hello World!";
    return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
