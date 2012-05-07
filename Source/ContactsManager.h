//
//  ContactsManager.h
//  Lumo
//
//  Created by Dan Kang on 5/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *sections;

+ (void)getFriends;

@end
