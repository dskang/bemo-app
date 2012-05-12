//
//  LumoViewController.m
//  Lumo
//
//  Created by Lumo on 4/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import "ContactsViewController.h"
#import "MapViewController.h"
#import "LumoAppDelegate.h"
#import "CallManager.h"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@end

@implementation ContactsViewController
@synthesize activityView = _activityView;
@synthesize contactsTableView = _contactsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setActivityView:nil];
    [super viewDidUnload];
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

- (IBAction)launchFeedback {
    [TestFlight openFeedbackView];
}

- (IBAction)refreshContacts:(id)sender {
    [self.activityView startAnimating];
    [ContactsManager getFriends];
    [TestFlight passCheckpoint:@"REFRESH_CONTACTS"];

    // Stop activity indicator after 5 seconds even if contacts have not been refreshed
    [NSTimer scheduledTimerWithTimeInterval:5 target:self.activityView selector:@selector(stopAnimating) userInfo:nil repeats:NO];
}

- (void)loadContacts {
    [self.activityView stopAnimating];
    [self.contactsTableView reloadData];
}

- (void)showReceiveScreen {
    [self performSegueWithIdentifier:@"showReceive" sender:nil];
}

- (NSDictionary *)getContactForSection:(NSInteger)section forRow:(NSInteger)row {
    NSArray *sortedSections = [[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *firstLetterOfContactName = [sortedSections objectAtIndex:section];
    NSArray *contacts = [myAppDelegate.contactsManager.sections valueForKey:firstLetterOfContactName];
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
    return [[myAppDelegate.contactsManager.sections valueForKey:[[[myAppDelegate.contactsManager.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
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
