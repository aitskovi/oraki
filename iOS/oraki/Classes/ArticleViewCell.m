//
//  ArticleViewCell.m
//  oraki
//
//  Created by Avi Itskovich on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewCell.h"
#import "Section.h"

@interface ArticleViewCell ()

@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;

@end

static void * kArticleViewContext = @"com.oraki.ArticleView";

@implementation ArticleViewCell

@synthesize section = _section;
@synthesize indicatorView = _indicatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicatorView setHidesWhenStopped:YES];
        [_indicatorView startAnimating];
        self.accessoryView = _indicatorView;
    }
    return self;
}

- (void)dealloc {
    [_section removeObserver:self forKeyPath:@"hasLoaded"];
    [_section release], _section = nil;
    [_indicatorView release], _indicatorView = nil;
    [super dealloc];
}

- (void)setSection:(Section *)section {
    if (section == _section) return;
    
    [_section removeObserver:self forKeyPath:@"hasLoaded"];
    [_section release];
    _section = [section retain];
    [_section addObserver:self forKeyPath:@"hasLoaded" options: NSKeyValueObservingOptionNew context:kArticleViewContext];
    self.textLabel.text = section.title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kArticleViewContext) {
        if ([keyPath isEqualToString:@"hasLoaded"]) {
            if ([self.section hasLoaded]) {
                [self.indicatorView stopAnimating];
            } else {
                [self.indicatorView startAnimating];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
