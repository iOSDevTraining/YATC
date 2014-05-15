//
//  MFFHomeViewController.h
//  TwitterTimeline
//
//  Created by Brian Preston on 4/9/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFFHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// @property(nonatomic, retain) IBOutlet UITableView *tableView;

@property (weak, nonatomic) NSNumber *userId;
@property (weak, nonatomic) NSString *screenName;

@end
