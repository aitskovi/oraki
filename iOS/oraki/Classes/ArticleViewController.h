//
//  ArticleViewController.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ArticleViewController : UIViewController {

}

- (id)initWithArticle:(NSString *)article;

@property (nonatomic, copy) NSString *articleTitle;
@property (nonatomic, retain) IBOutlet UITableView *sectionView;
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSMutableData *articleData;

@end
