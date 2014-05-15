//
//  MFFTweetCell.m
//  TwitterTimeline
//
//  Created by Brian Preston on 4/7/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import "MFFTweetCell.h"

@implementation MFFTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
