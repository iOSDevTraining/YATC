//
//  TCViewController.m
//  YATC
//
//  Created by Jacob Krall on 2/9/14.
//  Copyright (c) 2014 Jacob Krall. All rights reserved.
//

#import "TCViewController.h"

@interface TCViewController ()

@property NSArray *entries;

@end

@implementation TCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4; // self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

@end
