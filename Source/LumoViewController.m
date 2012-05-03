//
//  LumoViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "LumoViewController.h"
#import "MapViewController.h"
#import "LumoAppDelegate.h"

@interface LumoViewController ()
@property (weak, nonatomic) NSArray *contacts;
@property (strong, nonatomic) UITableView *tableView;
@property int numFriends;
@end

@implementation LumoViewController
@synthesize contacts = _contacts;
@synthesize tableView = _tableView;
@synthesize numFriends = _numFriends;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotContacts) name:@"loginAndFriendsSuccess" object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotContacts {
    self.numFriends = [myAppDelegate.contactArray count];
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
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    cell.textLabel.text = [[myAppDelegate.contactArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myAppDelegate.contactInfo = [myAppDelegate.contactArray objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPlaced) name:@"connRequested" object:nil];
    [myAppDelegate.locationRelay initiateConnection];
}

- (void)requestPlaced {
    [self performSegueWithIdentifier:@"gotoConnecting" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
