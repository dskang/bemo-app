//
//  Authentication.h
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@interface Authentication : NSObject <FBSessionDelegate>

@property (nonatomic, strong) Facebook *facebook;

// Indicates if we need to log into Bemo
// This is the case only when any of the three pieces of information changes:
// 1. Facebook access token
// 2. Device key (unique identifier)
// 3. Device token (for push notifications)
@property (nonatomic) BOOL loginRequired;

// Indicates if we need to log into Facebook
// This is the case when the user deauthorizes the app
@property (nonatomic) BOOL facebookLoginRequired;

- (void)authenticate;

@end
