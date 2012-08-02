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
    // Set up pull-to-refresh
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

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSDictionary *)getContactForSection:(NSInteger)section forRow:(NSInteger)row {
    NSArray *sections = [self sectionIndexTitlesForTableView:nil];
    NSString *sectionIndexTitle = [sections objectAtIndex:section];
    NSArray *contacts = [myAppDelegate.contactsManager.sections valueForKey:sectionIndexTitle];
    return [contacts objectAtIndex:row];
}

# pragma mark UITableViewDataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray arrayWithObjects:@"+", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Invite Friends";
    } else {
        NSArray *sections = [self sectionIndexTitlesForTableView:nil];
        NSString *sectionIndexTitle = [sections objectAtIndex:section];
        if ([myAppDelegate.contactsManager.sections valueForKey:sectionIndexTitle] == nil) {
            return nil;
        } else {
            return sectionIndexTitle;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sectionIndexTitlesForTableView:nil] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        NSArray *sections = [self sectionIndexTitlesForTableView:nil];
        NSString *sectionIndexTitle = [sections objectAtIndex:section];
        NSArray *contacts = [myAppDelegate.contactsManager.sections valueForKey:sectionIndexTitle];
        return [contacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];   
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Facebook";
        UIImage *logo = [UIImage imageNamed:@"fb_logo.png"];
        CGSize size;
        size.height = 22;
        size.width = 22;
        UIImage *scaledLogo = [[self class] scale:logo toSize:size];
        cell.imageView.image = scaledLogo;
        return cell;
    } else {
        NSDictionary *contact = [self getContactForSection:indexPath.section forRow:indexPath.row];
        cell.textLabel.text = [contact valueForKey:@"name"];
        cell.imageView.image = nil;
        return cell;
    }
}

# pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Let's share locations on Bemo.", @"message",
                                       nil];
        [myAppDelegate.auth.facebook dialog:@"apprequests" andParams:params andDelegate:myAppDelegate.auth];
        [self.contactsTableView deselectRowAtIndexPath:[self.contactsTableView indexPathForSelectedRow] animated:NO];
    } else {
        myAppDelegate.callManager.partnerInfo = [[self getContactForSection:indexPath.section forRow:indexPath.row] mutableCopy];
        [self showConnScreen];
    }
}

- (void)showConnScreen {
    [myAppDelegate.contactsManager getPartnerImage];
    [self performSegueWithIdentifier:@"showConnecting" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
