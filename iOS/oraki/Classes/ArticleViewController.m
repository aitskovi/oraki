//
//  ArticleViewController.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewController.h"
#import "JSON.h"
#import "Section.h"
#import "AudioText.h"
#import "ArticleViewCell.h"
#import "OrakiConstants.h"
#import "FliteManager.h"
#import "AudioPlayerView.h"

@interface ArticleViewController() <AudioPlayerViewDelegate>

@end

@implementation ArticleViewController

@synthesize articleTitle = _articleTitle;
@synthesize sectionView = _sectionView;
@synthesize indicatorView = _indicatorView;
@synthesize sections = _sections;
@synthesize articleData = _articleData;
@synthesize audioPlayer = _audioPlayer;
@synthesize audioPlayerView = _audioPlayerView;

- (id) initWithArticle:(NSString *)article {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        _articleTitle = [article copy];
        self.title = _articleTitle;
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:_articleTitle forKey:@"title"];
        NSURL *requestURL = [OrakiConstants urlForRequest:@"article_info" withParameters:parameters];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
        NSURLConnection *searchRequest = [NSURLConnection connectionWithRequest:request delegate:self];
        [searchRequest start];
        //[request release];
        
        _articleData = [[NSMutableData alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [[FliteManager sharedInstance] stopAllTasks];
    [_audioPlayer pause];
    [_audioPlayer release], _audioPlayer = nil;
    [_audioPlayerView release], _audioPlayerView = nil;
    [_articleTitle release], _articleTitle = nil;
    [_indicatorView release], _indicatorView = nil;
    [_sectionView release], _sectionView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.audioPlayerView setDelegate:self];
    if (self.articleData) {
        [self.indicatorView startAnimating];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ArticleViewCell *cell = (ArticleViewCell *)[tableView dequeueReusableCellWithIdentifier:@"article"];
    if (cell == nil) {
        cell = [[[ArticleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article"] autorelease];
    }
    
    Section *section = [self.sections objectAtIndex:indexPath.row];
    cell.section = section;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Section *currentSection = [self.sections objectAtIndex:indexPath.row];
    if ([currentSection hasLoaded]) {
        self.audioPlayer = [AVQueuePlayer queuePlayerWithItems:[currentSection sectionItems]];
        [self.audioPlayer play];
        [self.audioPlayerView setPlaying:YES];
    }
}

#pragma mark -
#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"It's Alive");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.articleData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Search Complete");
    
    NSString *jsonResponse = [[NSString alloc] initWithData:self.articleData encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *response = [parser objectWithString:jsonResponse];
    
    NSArray *sections = [response objectForKey:@"sections"];
    NSLog(@"Results are %@", self.sections);
    
    __block NSMutableArray *sectionObjects = [NSMutableArray array];
    [sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Section *section = [[[Section alloc] initWithDictionary:obj] autorelease];
        [sectionObjects addObject:section];
    }];
    
    [self.indicatorView stopAnimating];
    
    self.sections = sectionObjects;
    [self.sectionView reloadData];
    [jsonResponse release];
    self.articleData = nil;
}

#pragma mark -
#pragma mark AudioPlayerViewDelegate

- (void)playButtonWasPressed {
    if (!self.audioPlayer) return;
    if (self.audioPlayer.rate != 0) {
        [self.audioPlayer pause];
        [self.audioPlayerView setPlaying:NO];
    } else {
        [self.audioPlayer play];
        [self.audioPlayerView setPlaying:YES];
    }
}
@end
