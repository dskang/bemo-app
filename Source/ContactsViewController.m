//
//  LumoViewController.m
//  Lumo
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import "ContactsViewController.h"
#import "MapViewController.h"
#import "LumoAppDelegate.h"
#import "CallManager.h"

@interface ContactsViewController ()
@property (strong, nonatomic) UITableView *tableView;
@property int numFriends;
@end

@implementation ContactsViewController
@synthesize tableView = _tableView;
@synthesize numFriends = _numFriends;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotContacts) name:GET_FRIENDS_SUCCESS object:nil];
    
    // Listen for received calls
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConnScreen) name:CONN_RECEIVED object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gotContacts {
    // Reload data into contacts table
    self.numFriends = [myAppDelegate.contactsManager.contactsArray count];
    [self.tableView reloadData];
}

/******************************************************************************
 * Table view setup functions
 ******************************************************************************/

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return[NSArray arrayWithObjects:@"a", @"e", @"i", @"m", @"p", nil];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView = tableView; // Super hacky. Is there a better way?
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numFriends;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];   
    }
    cell.textLabel.text = [[myAppDelegate.contactsManager.contactsArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myAppDelegate.callManager.partnerInfo = [myAppDelegate.contactsManager.contactsArray objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConnScreen) name:CONN_REQUESTED object:nil];
    [CallManager initiateConnection];
}

- (void)showConnScreen {
    NSLog(@"showConnScreen called");
    [self performSegueWithIdentifier:@"gotoConnecting" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
