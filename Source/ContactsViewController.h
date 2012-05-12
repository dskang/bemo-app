//
//  LumoViewController.h
//  Lumo
//
//  Created by Lumo on 4/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"

@interface ContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PullToRefreshViewDelegate>

@end
