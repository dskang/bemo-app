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
@end

@implementation ContactsViewController
@synthesize tableView = _tableView;

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
    [self.tableView reloadData];
}

/******************************************************************************
 * Table view setup functions
 ******************************************************************************/

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    // If we want all indices
    return [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
    // If we only want existing indices
    //return [[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView = tableView; // Super hacky. Is there a better way?
    return [[myAppDelegate.contactsManager.sections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];   
    }
    cell.textLabel.text = [[[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] valueForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myAppDelegate.callManager.partnerInfo = [[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConnScreen) name:CONN_REQUESTED object:nil];
    [CallManager initiateConnection];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)showConnScreen {
    NSLog(@"showConnScreen called");
    [self performSegueWithIdentifier:@"gotoConnecting" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
