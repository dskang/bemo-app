//
//  CallManager.h
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *partnerInfo;

+ (void)initiateConnection;
+ (void)receiveConnection;
+ (void)endConnection;
+ (void)endConnectionWithID:(NSString *)targetID;

@end
