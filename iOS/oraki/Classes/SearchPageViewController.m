//
//  HomePageViewController.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchPageViewController.h"
#import "FliteManager.h"
#import "OrakiConstants.h"
#import "JSON.h"
#import "ArticleViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface SearchPageViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSMutableData *searchResultData;
@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;

@end

@implementation SearchPageViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize indicatorView = _indicatorView;
@synthesize results = _results;
@synthesize searchResultData = _searchResultsData;
@synthesize tapRecognizer = _tapRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // j initialization
        //_results = [[NSArray alloc] initWithObjects:@"Lebron James", @"James", @"Avi", @"Gilbert", nil];
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tap)];
        [self.view addGestureRecognizer:_tapRecognizer];
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        self.tableView.hidden = YES;
        self.tapRecognizer.enabled = YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:searchText forKey:@"query"];
    NSURL *requestURL = [OrakiConstants urlForRequest:@"search" withParameters:parameters];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    NSURLConnection *searchRequest = [NSURLConnection connectionWithRequest:request delegate:self];
    [searchRequest start];
    
    self.searchResultData = [NSMutableData dataWithCapacity:0];
    [self.indicatorView startAnimating];
}

#pragma mark - 
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.hidden = YES;
    self.tapRecognizer.enabled = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"search"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"search"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    cell.textLabel.text = [self.results objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleViewController *articleController = [[ArticleViewController alloc] initWithArticle:[self.results objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:articleController animated:YES];
    [articleController release];
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
    
    NSString *jsonRespose = [[NSString alloc] initWithData:self.searchResultData encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    self.results = [parser objectWithString:jsonRespose];
    NSLog(@"Results are %@", self.results);
    [self.indicatorView stopAnimating];
    self.tableView.hidden = NO;
    self.tapRecognizer.enabled = NO;
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = YES;
    [jsonRespose release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.tableView.userInteractionEnabled = YES;
    [self.indicatorView stopAnimating];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oh Noes!" message:@"Something went wrong while we were talking to Wikipedia. Try again and we'll try to be nicer to it." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease];
    [alert show];
}

#pragma mark -
#pragma mark Touch Handling

- (void)tap {
    [self.searchBar resignFirstResponder];
}

@end
