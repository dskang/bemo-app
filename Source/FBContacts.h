//
//  FBContacts.h
//  Lumo
//
//  Created by Harvest Zhang on 4/19/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol ContactRequestDelegate <NSObject>

@required
- (void) contactsAcquired: (BOOL)success;

@end

@interface FBContacts : NSObject <FBRequestDelegate>

@property (strong, nonatomic) id delegate;

- (void)requestContacts;

@end
