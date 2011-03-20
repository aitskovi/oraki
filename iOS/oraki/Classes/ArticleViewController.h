//
//  ArticleViewController.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AudioPlayerView;

@interface ArticleViewController : UIViewController {

}

- (id)initWithArticle:(NSString *)article;

@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, retain) IBOutlet UITableView *sectionView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, retain) IBOutlet AudioPlayerView *audioPlayerView;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableData *articleData;
@property (nonatomic, retain) AVQueuePlayer *audioPlayer;

@end
