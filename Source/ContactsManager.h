//
//  ContactsManager.h
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBRequest.h"

@interface ContactsManager : NSObject <FBRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *sections;

+ (void)getFriends;
- (void)getPartnerImage;

@end
