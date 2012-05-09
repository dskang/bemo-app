//
//  ContactsManager.h
//  Lumo
//
//  Created by Lumo on 5/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *sections;

+ (void)getFriends;

@end
