//
//  AudioPlayerView.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioPlayerView.h"


@implementation AudioPlayerView

@synthesize playButton = _playButton;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;

- (void)commonInit {
    _playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.playButton sizeToFit];
    [self addSubview:_playButton];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.playButton sizeToFit];
    [self.playButton setCenter:self.center];
}

- (void)dealloc {
    [super dealloc];
}

@end
