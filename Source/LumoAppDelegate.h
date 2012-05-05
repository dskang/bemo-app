//
//  LumoAppDelegate.h
//  Lumo
//
//  Created by Harvest Zhang on 4/5/12.
//  Copyright (c) 2012 Princeton University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationRelay.h"
#import "LumoRequest.h"

#define myAppDelegate ((LumoAppDelegate *)[[UIApplication sharedApplication] delegate])
#define BASE_URL @"http://lumo.herokuapp.com"

@interface LumoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LocationRelay *locationRelay;
@property (strong, nonatomic) NSArray *contactArray;
@property (strong, nonatomic) NSDictionary *myInfo;
@property (strong, nonatomic) NSDictionary *contactInfo;
@property (strong, nonatomic) NSString *sessionToken;

@end
