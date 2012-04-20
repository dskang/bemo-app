//
//  rdvFBContacts.h
//  Rendezvous
//
//  Created by Harvest Zhang on 4/19/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface rdvFBContacts : NSObject <FBRequestDelegate> {

}

@property (strong, nonatomic) Facebook* facebook;
@property (strong, nonatomic) NSArray* contactArray;

- (void)requestContacts;

@end
