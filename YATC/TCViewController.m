//
//  TCViewController.m
//  YATC
//
//  Created by Jacob Krall on 2/9/14.
//  Copyright (c) 2014 Jacob Krall. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TCViewController.h"

@interface TCViewController ()

@property NSArray *entries;

// Twitter connection code shamelessly stolen from
// https://dev.twitter.com/docs/ios/making-api-requests-slrequest
@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation TCViewController

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entries = @[];
    [self fetchTimelineForUser];
}

- (void)fetchTimelineForUser
{
    if (!self.accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];

        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/home_timeline.json"];
                 NSDictionary *params = @{@"count" : @"100", @"include_entities": @"false"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];

                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              NSError *jsonError;
                              NSArray *timelineData =
                              [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              if (timelineData) {
                                  self.entries = timelineData;
                                  NSLog(@"got %ld", (long)(timelineData.count));
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.tableView reloadData];
                                  });
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %ld",
                                    (long)(urlResponse.statusCode));
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    } else {
        NSLog(@"!userHasAccessToTwitter");
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary* tweet = self.entries[indexPath.row];
    
    cell.textLabel.text = tweet[@"user"][@"screen_name"];
    cell.detailTextLabel.text = tweet[@"text"];
    return cell;
}

@end
