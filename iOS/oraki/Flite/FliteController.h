//
//  Flite.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum FliteVoiceType {
    FliteVoiceKAL = 0,
    FliteVoiceKAL16,
    FliteVoiceRMS,
    FliteVoiceAWB,
    FliteVoiceSLT
} FliteVoiceType;

@interface FliteController : NSObject {
    NSMutableArray *_queue;
}

-(NSData *)convertTextToData:(NSString *)text;
-(void)setPitch:(float)pitch variance:(float)variance speed:(float)speed;
-(void)setVoice:(FliteVoiceType)type;

@end
