//
//  AudioPlayerView.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioPlayerViewDelegate;

@interface AudioPlayerView : UIView {
    
}

@property (nonatomic, assign) id <AudioPlayerViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;

- (void)setPlaying:(BOOL)playing;
- (IBAction)playButtonWasPressed:(UIButton *)button;
@end

@protocol AudioPlayerViewDelegate <NSObject>

@required
- (void)playButtonWasPressed;

@end
