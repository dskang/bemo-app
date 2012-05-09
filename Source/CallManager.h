//
//  CallManager.h
//  Lumo
//
//  Created by Lumo on 5/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CallManager : NSObject

@property (nonatomic, strong) NSDictionary *partnerInfo;

+ (void)initiateConnection;
+ (void)receiveConnection;
+ (void)endConnection;

@end
