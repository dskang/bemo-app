//
//  RendezvousViewController.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "RendezvousViewController.h"
#import "FBContacts.h"

@interface RendezvousViewController ()
@property (strong, nonatomic) NSArray* contacts;
@property (strong, nonatomic) NSArray* indices;
@property (strong, nonatomic) FBContacts* FBContacts;
@end

@implementation RendezvousViewController
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
