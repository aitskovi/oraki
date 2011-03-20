//
//  AudioText.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioText : NSObject {
    
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSData *audioData;

- (id)initWithText:(NSString *)text;
- (BOOL)hasLoaded;

@end
