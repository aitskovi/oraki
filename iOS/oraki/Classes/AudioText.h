//
//  AudioText.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioText : NSObject {
    
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) AVAsset *audioAsset;

- (id)initWithText:(NSString *)text;
- (BOOL)hasLoaded;

@end
