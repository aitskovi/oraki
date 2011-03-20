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
#import "OrakiConstants.h"

@implementation ArticleViewController

@synthesize articleTitle = _articleTitle;
@synthesize sectionView = _sectionView;
@synthesize sections = _sections;
@synthesize articleData = _articleData;

- (id) initWithArticle:(NSString *)article {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        _articleTitle = [article copy];
        self.title = _articleTitle;
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:_articleTitle forKey:@"title"];
        NSURL *requestURL = [OrakiConstants urlForRequest:@"article" withParameters:parameters];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
        NSURLConnection *searchRequest = [NSURLConnection connectionWithRequest:request delegate:self];
        [searchRequest start];
        //[request release];
        
        _articleData = [[NSMutableData alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [_articleTitle release], _articleTitle = nil;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"article"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"article"] autorelease];
    }
    
    if (!self.sections) {
        cell.textLabel.text = @"Loading ...";
    } else {
        cell.textLabel.text = [[self.sections objectAtIndex:indexPath.row] title];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger resultSize = [self.sections count];
    if (resultSize == 0) {
        return 1;
    }
    return resultSize;
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
    [self.articleData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Search Complete");
    
    NSString *jsonRespose = [[NSString alloc] initWithData:self.articleData encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *sections = [parser objectWithString:jsonRespose];
    NSLog(@"Results are %@", self.sections);
    
    __block NSMutableArray *sectionObjects = [NSMutableArray array];
    [sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Section *section = [[[Section alloc] initWithDictionary:obj] autorelease];
        [sectionObjects addObject:section];
    }];
    
    self.sections = sectionObjects;
    
    [self.sectionView reloadData];
    [jsonRespose release];
}

@end
