//
//  HomePageViewController.m
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchPageViewController.h"
#import "FliteController.h"
#import <AVFoundation/AVFoundation.h>

@interface SearchPageViewController () <UISearchBarDelegate, FliteControllerDelegate>
@end

@implementation SearchPageViewController

@synthesize searchBar = _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // j initialization

    }
    return self;
}

- (void)dealloc {
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
    NSLog(@"Search");
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
#pragma mark FliteController Delegate

- (void)finishedProcessingData:(NSData *)data dataId:(NSUInteger)dataId {
    NSLog(@"Done");
}
@end
