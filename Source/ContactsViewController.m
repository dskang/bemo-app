//
//  BemoViewController.m
//  Bemo
//
//  Created by Lumo Labs on 4/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import "ContactsViewController.h"
#import "MapViewController.h"
#import "BemoAppDelegate.h"
#import "CallManager.h"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (strong, nonatomic) PullToRefreshView *refreshView;
@end

@implementation ContactsViewController
@synthesize contactsTableView = _contactsTableView;
@synthesize refreshView = _refreshView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)self.contactsTableView];
    [self.refreshView setDelegate:self];
    [self.contactsTableView addSubview:self.refreshView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setRefreshView:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myAppDelegate.appState = IDLE_STATE;
    // Show receiving screen when receiving a call
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReceiveScreen) name:CONN_WAITING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadContacts) name:GET_FRIENDS_SUCCESS object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.contactsTableView deselectRowAtIndexPath:[self.contactsTableView indexPathForSelectedRow] animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [self refreshContacts];
}

- (void)refreshContacts {
    [ContactsManager getFriends];
    
#ifdef TESTFLIGHT
    [TestFlight passCheckpoint:@"REFRESH_CONTACTS"];
#endif

#ifdef MIXPANEL
    [[MixpanelAPI sharedAPI] track:@"REFRESH_CONTACTS"];
#endif
}

- (void)loadContacts {
    [self.contactsTableView reloadData];
    [self.refreshView finishedLoading];
}

- (void)showReceiveScreen {
    [self performSegueWithIdentifier:@"showReceive" sender:nil];
}

- (NSDictionary *)getContactForSection:(NSInteger)section forRow:(NSInteger)row {
    NSArray *sortedSections = [[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *sectionIndexTitle = [sortedSections objectAtIndex:section];
    NSArray *contacts = [myAppDelegate.contactsManager.sections valueForKey:sectionIndexTitle];
    return [contacts objectAtIndex:row];
}

# pragma mark UITableViewDataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[myAppDelegate.contactsManager.sections allKeys] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionIndexTitle = [[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[myAppDelegate.contactsManager.sections valueForKey:sectionIndexTitle] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];   
    }
    NSDictionary *contact = [self getContactForSection:indexPath.section forRow:indexPath.row];
    cell.textLabel.text = [contact valueForKey:@"name"];
    return cell;
}

# pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myAppDelegate.callManager.partnerInfo = [[self getContactForSection:indexPath.section forRow:indexPath.row] mutableCopy];
    [self showConnScreen];
}

- (void)showConnScreen {
    [myAppDelegate.contactsManager getPartnerImage];
    [self performSegueWithIdentifier:@"showConnecting" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
