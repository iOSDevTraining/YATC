//
//  MFFViewController.m
//  TwitterTimeline
//
//  Created by Brian Preston on 3/29/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "MFFViewController.h"
#import "MFFTweetCell.h"

@interface MFFViewController ()

@property (strong, nonatomic) NSArray *array;

@end

@implementation MFFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self twitterTimeline];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) twitterTimeline {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    
    // Asks for the Twitter accounts configured on the device
    
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
    {
        // if we have access to the Twitter accounts configured on the device we will contact the Twitter API
        
        if (granted) {
            // Retrieve array of twitter accounts on device
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            // if there is at least one account we will contact the Twitter API
            if ([arrayOfAccounts count] > 0) {
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                // API call that returns entires in a user's timeline
                NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                // the requestAPI requires us to tell it how much data to return so we use a NSDictionary to set the count
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:@"100" forKey:@"count"];
                [parameters setObject:@"1" forKey:@"include_entities"];
                // this is where we are getting the data using SLRequest
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:parameters];
                posts.account = twitterAccount;
                // the postRequest: method call now accesses the NSData object returned
                [posts performRequestWithHandler:^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error) {
                    // The NSJSONSerialization class is then used to parse the data returned and assign it to our array
                    self.array = [NSJSONSerialization JSONObjectWithData:response
                                                                 options:NSJSONReadingMutableLeaves
                                                                   error:&error];
                    if (self.array.count != 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }];
            }
        } else {
            // Handle failure to get account access
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

#pragma mark Table View Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Returns the number of rows for the table view using the array instance variable
    return [self.array count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MFFTweetCell *cell = (MFFTweetCell *) [self.tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
    NSDictionary *tweet = self.array[indexPath.row];
    cell.name.text = [tweet valueForKeyPath:@"user.name"];
    cell.username.text = [tweet valueForKeyPath:@"user.screen_name"];
    cell.tweet.text = tweet[@"text"];
    // following 2 lines are supposed to make the text start at top left
    cell.tweet.numberOfLines = 0;
    [cell.tweet sizeToFit];
    
    // image takes a bit more
    NSString *profileImageURL = [tweet valueForKeyPath:@"user.profile_image_url"];
    NSURL *imageUrl = [[NSURL alloc] initWithString:profileImageURL];
    UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    cell.profileImageView.image = profileImage;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // when a user selects a row this will de-select the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
