//
//  HomePageViewController.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchPageViewController.h"
#import "FliteController.h"
#import "OrakiConstants.h"
#import <AVFoundation/AVFoundation.h>

@interface SearchPageViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FliteControllerDelegate>

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSMutableData *searchResultData;

@end

@implementation SearchPageViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize results = _results;
@synthesize searchResultData = _searchResultsData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // j initialization
        _results = [[NSArray alloc] initWithObjects:@"Lebron", @"James", @"Avi", @"Gilbert", nil];
    }
    return self;
}

- (void)dealloc {
    [_searchBar release], _searchBar = nil;
    [_tableView release], _tableView = nil;
    [_results release], _results = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:searchText forKey:@"query"];
    NSURL *requestURL = [OrakiConstants urlForRequest:@"search" withParameters:parameters];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    NSURLConnection *searchRequest = [NSURLConnection connectionWithRequest:request delegate:self];
    [searchRequest start];
    
    self.searchResultData = [NSMutableData dataWithCapacity:0];
}

#pragma mark - 
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    FliteController *flite = [[FliteController alloc] init];
    flite.delegate = self;
    NSUInteger dataId = [flite convertTextToData:@"Hello..."];
    NSLog(@"Finished");
    /*NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:textData error:&error];
    if (!player) {
        NSLog(@"Error %@", error);
    } else {
        [player play];
    }*/
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"search"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"search"];
    }
    cell.textLabel.text = [self.results objectAtIndex:indexPath.row];
    
    return [cell autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected");
}

#pragma mark -
#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"It's Alive");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.searchResultData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Search Complete");
}

#pragma mark -
#pragma mark FliteController Delegate

- (void)finishedProcessingData:(NSData *)data dataId:(NSUInteger)dataId {
    NSLog(@"Done");
}
@end
