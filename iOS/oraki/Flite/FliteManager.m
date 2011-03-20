//
//  Flite.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FliteManager.h"
#import "Flite.h"

cst_voice *register_cmu_us_kal();
cst_voice *register_cmu_us_kal16();
cst_voice *register_cmu_us_rms();
cst_voice *register_cmu_us_awb();
cst_voice *register_cmu_us_slt();
cst_wave *sound;
cst_voice *voice;

@interface FliteManager ()

- (void)finishedProcessingData:(NSData *)data withId:(NSUInteger)dataId;

@end

@implementation FliteManager

@synthesize delegate = _delegate;

+ (id)sharedInstance {
    static FliteManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FliteManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
        flite_init();
        [self setVoice:FliteVoiceKAL];
    }
    return self;
}

- (void)convertTextToData:(NSString *)text completion:(void (^)(NSData *data))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableString *filteredString = [NSMutableString string];
        if ([text length] > 1) {
            for (int i = 0; i < [text length]; i++) { 
                unichar ch = [text characterAtIndex:i];
                [filteredString appendFormat:@"%c", ch];
            }
        }
        sound = flite_text_to_wave([filteredString UTF8String], voice);
        
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        NSString *tempPath = NSTemporaryDirectory();
        tempPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.wav", newUniqueIdString]];
        CFRelease(newUniqueId);
        CFRelease(newUniqueIdString);
        
        char *path = (char *)[tempPath UTF8String];
        cst_wave_save_riff(sound, path);
        
        NSData *data = [NSData dataWithContentsOfMappedFile:tempPath];
        if (completion) completion(data);
    });
}

- (void)setPitch:(float)pitch variance:(float)variance speed:(float)speed {
    feat_set_float(voice->features,"int_f0_target_mean", pitch);
    feat_set_float(voice->features,"int_f0_target_stddev",variance);
    feat_set_float(voice->features,"duration_stretch",speed);
}

- (void)setVoice:(FliteVoiceType)type { 
    switch (type) {
        case FliteVoiceKAL:
            voice = register_cmu_us_kal();
            break;
        case FliteVoiceKAL16:
            voice = register_cmu_us_kal16();
            break;
        case FliteVoiceRMS:
            voice = register_cmu_us_rms();
            break;
        case FliteVoiceAWB:
            voice = register_cmu_us_awb();
            break;
        case FliteVoiceSLT:
            voice = register_cmu_us_slt();
            break;
    }
}

#pragma mark -
#pragma mark Delegate Protocol

- (void)finishedProcessingData:(NSData *)data withId:(NSUInteger)dataId {
    [self.delegate finishedProcessingData:data dataId:dataId];
}

@end
