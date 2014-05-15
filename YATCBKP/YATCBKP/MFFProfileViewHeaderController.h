//
//  MFFProfileView.h
//
//  Original intent was for this to be a reusable view component on top of a table
//
//  Created by Brian Preston on 4/14/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFFProfileViewHeaderController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *numFollowers;
@property (nonatomic, weak) IBOutlet UILabel *numFollowing;

@end
