//
//  ParseHelper.h
//  project-monitor
//
//  Created by Dimitri Roche on 1/29/14.
//  Copyright (c) 2014 Dimitri Roche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseHelper : NSObject

+ (void)initialize:(NSDictionary *)launchOptions;
+ (void)saveTestObjectInBackground;

@end
