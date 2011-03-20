//
//  Section.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"
#import "AudioText.h"

@implementation Section

@synthesize title = _title;
@synthesize paragraphs = _paragraphs;


- (id)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [self init])) {
        _title = [[dictionary objectForKey:@"name"] copy];
        
        NSMutableArray *paragraphs = [[NSMutableArray alloc] initWithCapacity:0];
        NSArray *textForParagraphs = [dictionary objectForKey:@"paragraphs"];
        [textForParagraphs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AudioText *text = [[AudioText alloc] initWithText:obj];
            
            [paragraphs addObject:text];
        }];
        _paragraphs = paragraphs;
    }
    return self;
}

- (void)dealloc {
    [_title release], _title = nil;
    [_paragraphs release], _paragraphs = nil;
    [super dealloc];
}

- (NSArray *)sectionItems {
    if (![self hasLoaded]) return nil;
    __block NSMutableArray *sectionItems = [[NSMutableArray alloc] init];
    [self.paragraphs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [sectionItems addObject:[obj audioData]];
    }];
    return sectionItems;
}

- (BOOL)hasLoaded {
    for (AudioText *paragraph in self.paragraphs) {
        if (![paragraph hasLoaded]) {
            return NO;
        }
    }
    return YES;
}

@end
