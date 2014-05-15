//
//  MFFTwitterTableViewController.h
//  TwitterTimeline
//
//  Created by Brian Preston on 4/16/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFFTwitterTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSNumber *userId;
@property (weak, nonatomic) NSString *screenName;

@end
