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
@property (strong, nonatomic) FBContacts* fbContacts;
@property (strong, nonatomic) UITableView* tableView;
@property int numFriends;
@end

@implementation RendezvousViewController
@synthesize contacts = _contacts;
@synthesize indices = _indices;
@synthesize fbContacts = _fbContacts;
@synthesize tableView = _tableView;
@synthesize numFriends = _numFriends;

- (FBContacts *)fbContacts {
    if (!_fbContacts) {
        _fbContacts = [[FBContacts alloc] init];
        [_fbContacts setDelegate:self];
    }
    return _fbContacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contacts = nil;
    [self.fbContacts requestContacts];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)contactsAcquired:(BOOL)success {
    NSLog(@"RendezvousViewController has the contacts!");
    self.contacts = [self.fbContacts.contactArray objectForKey:@"data"];
    self.numFriends = [self.contacts count];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView = tableView; // Super hacky. Is there a better way?
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numFriends;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.textLabel.text = [[self.contacts objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"gotoMapView" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
