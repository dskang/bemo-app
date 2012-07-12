//
//  BemoViewController.h
//  Bemo
//
//  Created by Lumo Labs on 4/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"

@interface ContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PullToRefreshViewDelegate>

@end
