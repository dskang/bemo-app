//
//  RendezvousViewController.m
//  Rendezvous
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "RendezvousViewController.h"
#import "MapViewController.h"

@interface RendezvousViewController ()
@property (strong, nonatomic) NSArray* contacts;
@property (strong, nonatomic) NSArray* indices;
@property (strong, nonatomic) FBContacts* FBContacts;
@property (strong, nonatomic) UITableView* tableView;
@property int numFriends;
@end

@implementation RendezvousViewController
@synthesize contacts = _contacts;
@synthesize indices = _indices;
@synthesize FBContacts = _FBContacts;
@synthesize tableView = _tableView;
@synthesize numFriends = _numFriends;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _contacts = nil;
    _FBContacts = [[FBContacts alloc] init];
    [_FBContacts setDelegate:self];
    [_FBContacts requestContacts];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)contactsAcquired:(BOOL)success {
    NSLog(@"RendezvousViewController has the contacts!");
    _contacts = [_FBContacts.contactArray objectForKey:@"data"];
    _numFriends = [_contacts count];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _tableView = tableView; // Super hacky. Is there a better way?
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numFriends;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.textLabel.text = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"gotoConnecting" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
