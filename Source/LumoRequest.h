//
//  LumoRequest.h
//  Lumo
//
//  Created by Lumo on 5/5/12.
//  Copyright (c) 2012 Lumo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LumoRequest : NSObject

+ (void)postRequestToURL:(NSString *)url withDict:(NSDictionary *)dict successNotification:(NSString *)successNotification;

@end
