//
//  Section.h
//  oraki
//
//  Created by Avi Itskovich on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Section : NSObject {
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSArray *paragraphs;

//- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
