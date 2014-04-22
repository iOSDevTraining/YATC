//
//  MFFViewController.h
//  TwitterTimeline
//
//  Created by Brian Preston on 3/29/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFFViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
