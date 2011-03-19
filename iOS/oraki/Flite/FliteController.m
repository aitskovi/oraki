//
//  Flite.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FliteController.h"
#import "Flite.h"

cst_voice *register_cmu_us_kal();
cst_voice *register_cmu_us_kal16();
cst_voice *register_cmu_us_rms();
cst_voice *register_cmu_us_awb();
cst_voice *register_cmu_us_slt();
cst_wave *sound;
cst_voice *voice;

@implementation FliteController

- (id)init {
    if ((self = [super init])) {
        flite_init();
        [self setVoice:FliteVoiceKAL];
    }
    return self;
}

- (NSData *)convertTextToData:(NSString *)text {
    // TODO: Perform computation on block with delegate callback on completion
    NSMutableString *filteredString = [NSMutableString string];
    if ([text length] > 1) {
        for (int i = 0; i < [text length]; i++) { 
            unichar ch = [text characterAtIndex:i];
            [filteredString appendFormat:@"%c", ch];
        }
    }
    sound = flite_text_to_wave([filteredString UTF8String], voice);
    
    NSString *tempPath = NSTemporaryDirectory();
    tempPath = [tempPath stringByAppendingPathComponent:@"temp.wav"];
    
    char *path = (char *)[tempPath UTF8String];
    cst_wave_save_riff(sound, path);
    
    return [NSData dataWithContentsOfMappedFile:tempPath];
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

@end
