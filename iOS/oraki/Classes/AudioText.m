//
//  AudioText.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioText.h"
#import "FliteManager.h"

@implementation AudioText

@synthesize text = _text;
@synthesize audioAsset = audioAsset;

- (id)initWithText:(NSString *)text {
    if ((self = [self init])) {
        _text = [text copy];
        
        FliteManager *flite = [FliteManager sharedInstance];
        __block AudioText *_self = self;
        [flite convertTextToData:text completion:^(AVAsset *data) {
            AudioText *self = _self;
            self.audioAsset = data;
            [self willChangeValueForKey:@"hasLoaded"];
            [self didChangeValueForKey:@"hasLoaded"];
        }];
    }
    return self;
}

- (BOOL)hasLoaded {
    if (self.audioAsset) return YES;
    return NO;
}

@end
