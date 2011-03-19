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

@protocol FliteControllerDelegate;

@interface FliteController : NSObject {
    id <FliteControllerDelegate> delegate;
}

@property (nonatomic, assign) id <FliteControllerDelegate> delegate;

- (NSUInteger)convertTextToData:(NSString *)text;
- (void)setPitch:(float)pitch variance:(float)variance speed:(float)speed;
- (void)setVoice:(FliteVoiceType)type;

@end

@protocol FliteControllerDelegate <NSObject>

@required
- (void)finishedProcessingData:(NSData *)data dataId:(NSUInteger)dataId;

@end