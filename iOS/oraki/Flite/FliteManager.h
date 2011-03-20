//
//  Flite.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum FliteVoiceType {
    FliteVoiceKAL = 0,
    FliteVoiceKAL16,
    FliteVoiceRMS,
    FliteVoiceAWB,
    FliteVoiceSLT
} FliteVoiceType;

@interface FliteManager : NSObject {
    
}

+ (id)sharedInstance;
- (void)convertTextToData:(NSString *)text completion:(void(^)(AVAsset *data))completion;
- (void)setPitch:(float)pitch variance:(float)variance speed:(float)speed;
- (void)setVoice:(FliteVoiceType)type;
- (void)stopAllTasks;

@end