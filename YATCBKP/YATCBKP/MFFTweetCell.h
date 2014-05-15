//
//  MFFTweetCell.h
//  TwitterTimeline
//
//  Created by Brian Preston on 4/7/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFFTweetCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *tweet;
@property (nonatomic, weak) IBOutlet UILabel *time;

@end
