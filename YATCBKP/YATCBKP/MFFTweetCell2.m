//
//  MFFTweetCell2.m
//  TwitterTimeline
//
//  Created by Brian Preston on 4/16/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import "MFFTweetCell2.h"

@implementation MFFTweetCell2

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure controls
        self.tweet = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 280, 35)];
        self.tweet.textColor = [UIColor blackColor];
        self.tweet.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
//        self.tweet.numberOfLines = 0;
//        [self.tweet sizeToFit];
        
        [self addSubview:self.tweet];
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
