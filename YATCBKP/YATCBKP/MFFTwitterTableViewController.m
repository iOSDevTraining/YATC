//
//  MFFTwitterTableViewController.m
//  TwitterTimeline
//
//  Created by Brian Preston on 4/16/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "MFFTwitterTableViewController.h"
#import "MFFTweetCell2.h"

@interface MFFTwitterTableViewController ()

@property (strong, nonatomic) NSArray *array;

@end

@implementation MFFTwitterTableViewController {
    UITableView *tableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self twitterUserProfile];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // add to canvas
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) twitterUserProfile {
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
                 
                 // [parameters setObject:_userId forKey:@"user_id"];
                 [parameters setObject:_screenName forKey:@"screen_name"];
                 
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
                             NSDictionary *firstTweet = self.array[0];
                             NSLog(@"first Tweet : %@", firstTweet[@"text"]);
                             [tableView reloadData];
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


#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.array count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TwitterCell";
    
    MFFTweetCell2 *cell = (MFFTweetCell2 *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MFFTweetCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *tweet = self.array[indexPath.row];
    cell.name.text = [tweet valueForKeyPath:@"user.name"];
    cell.username.text = [tweet valueForKeyPath:@"user.screen_name"];
    cell.tweet.text = tweet[@"text"];

    return cell;
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %d row", indexPath.row);
}

@end
