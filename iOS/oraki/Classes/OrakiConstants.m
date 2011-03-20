//
//  OrakiConstants.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrakiConstants.h"


@implementation OrakiConstants

+ (NSURL *)urlForRequest:(NSString *)request {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://oraki-backend.appspot.com/%@", request]];
}

+ (NSURL *)urlForRequest:(NSString *)request withParameters:(NSDictionary *)parameters {
    NSURL *requestURL = [self urlForRequest:request];
    
    NSString *url = [requestURL absoluteString];
    NSUInteger i = 0;
    
    for (id key in parameters) {
        if ( i == 0) {
            url = [url stringByAppendingFormat:@"%?%@=%@", key, [parameters objectForKey:key]];
        } else {
            url = [url stringByAppendingFormat:@"%&%@=%@", key, [parameters objectForKey:key]];
        }
        i++;
    }
    return [NSURL URLWithString:url];
}

@end
