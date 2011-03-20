//
//  AudioPlayerView.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioPlayerView.h"


@implementation AudioPlayerView

@synthesize delegate = _delegate;
@synthesize playButton = _playButton;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;

- (void)dealloc {
    _delegate = nil;
    [_playButton release], _playButton = nil;
    [_previousButton release], _previousButton = nil;
    [_nextButton release], _nextButton = nil;
    [super dealloc];
}

#pragma mark -

- (void)setPlaying:(BOOL)playing {
    if (playing) {
        [self.playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)playButtonWasPressed:(UIButton *)button {
    [self.delegate playButtonWasPressed];
}

@end
