//
//  OrakiConstants.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrakiConstants : NSObject {
}

+ (NSURL *)urlForRequest:(NSString *)request;
+ (NSURL *)urlForRequest:(NSString *)request withParameters:(NSDictionary *)parameters;
@end
