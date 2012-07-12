//
//  BemoRequest.h
//  Bemo
//
//  Created by Lumo Labs on 5/5/12.
//  Copyright (c) 2012 Bemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BemoRequest : NSObject

+ (void)postRequestToURL:(NSString *)url withDict:(NSDictionary *)dict successNotification:(NSString *)successNotification;

@end
