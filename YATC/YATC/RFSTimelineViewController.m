//
//  RFSTimelineViewController.m
//  YATC
//
//  Created by Josh Brown on 2/7/14.
//  Copyright (c) 2014 Roadfire Software. All rights reserved.
//

#import "RFSTimelineViewController.h"

@import Accounts;
@import Social;

@interface RFSTimelineViewController ()

@property ACAccountStore *accountStore;
@property NSArray *tweets;

@end

@implementation RFSTimelineViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _accountStore = [[ACAccountStore alloc] init];
        _tweets = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchTimeline];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *tweet = self.tweets[indexPath.row];
    
    NSString *username = [tweet valueForKeyPath:@"user.screen_name"];
    NSString *tweetText = [tweet valueForKeyPath:@"text"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", username];
    cell.detailTextLabel.text = tweetText;
    
    return cell;
}

#pragma mark - Twitter

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchTimeline
{
    if ([self userHasAccessToTwitter])
    {
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/home_timeline.json"];
                 NSDictionary *params = @{@"count" : @"100"};
                 
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (responseData)
                      {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300)
                          {
                              NSError *jsonError;
                              NSArray *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              
                              if (timelineData)
                              {
                                  NSLog(@"Timeline Response: %@\n", timelineData);
                                  self.tweets = timelineData;
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.tableView reloadData];
                                  });
                              }
                              else
                              {
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else
                          {
                              NSLog(@"The response status code is %ld", (long)urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else
             {
                 NSLog(@"Access not granted: %@", [error localizedDescription]);
             }
         }];
    }
    else
    {
        NSLog(@"User does not have access to Twitter. Did you configure Twitter in the Settings app?");
    }
}

@end
