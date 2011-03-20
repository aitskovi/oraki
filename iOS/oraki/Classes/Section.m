//
//  Section.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"
#import "AudioText.h"

static void * kSectionContext = @"com.oraki.Section";

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
            [text addObserver:self forKeyPath:@"hasLoaded" options:NSKeyValueObservingOptionNew context:kSectionContext];
            [paragraphs addObject:text];
        }];
        _paragraphs = paragraphs;
    }
    return self;
}

- (void)dealloc {
    [_title release], _title = nil;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_paragraphs count])];
    [_paragraphs removeObserver:self fromObjectsAtIndexes:indexSet forKeyPath:@"hasLoaded"];
    [_paragraphs release], _paragraphs = nil;
    [super dealloc];
}

- (NSArray *)sectionItems {
    if (![self hasLoaded]) return nil;
    __block NSMutableArray *sectionItems = [[NSMutableArray alloc] init];
    [self.paragraphs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:[obj audioAsset]];
        [sectionItems addObject:item];
        [item release];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kSectionContext) {
        if ([keyPath isEqualToString:@"hasLoaded"]){
            if ([self hasLoaded]) {
                [self willChangeValueForKey:@"hasLoaded"];
                [self didChangeValueForKey:@"hasLoaded"];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
