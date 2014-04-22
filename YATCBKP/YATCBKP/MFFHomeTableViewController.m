//
//  MFFHomeTableViewController.m
//  TwitterTimeline
//
//  Created by Brian Preston on 4/17/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "MFFTweetCellMin.h"
#import "MFFProfileViewHeaderController.h"
#import "MFFTwitterTableViewController.h"

#import "MFFHomeTableViewController.h"

@interface MFFHomeTableViewController ()

@property (strong, nonatomic) NSArray *array;

@end

@implementation MFFHomeTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [refresh addTarget:self action:@selector(twitterHome)
     
    forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    [self twitterHome];
}

- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) newTweet {
    // Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler. Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch (result) {
                // this means the user cancelled without sending the tweet
            case SLComposeViewControllerResultCancelled:
                break;
                // this means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                break;
            default:
                break;
        }
    };
    
    // set the initial body of the Tweet
    [tweetSheet setInitialText:@"test tweet from iOS app"];
    
    // Adds an image to the tweet. For demo purposes, assume we have an image
    // named 'larry.png' that we want to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"newTweetSmall3.png"]]) {
        NSLog(@"Unable to add the image");
    }
    
    // Add an URL to the tweet. You can add multiple URLs.
    if (![tweetSheet addURL:[NSURL URLWithString:@"http://www.twitter.com"]]) {
        NSLog(@"Unable to add the URL!");
    }
    
    // Presents the tweet sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented");
    }];
    
}

-(void) twitterHome {
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
                 NSURL *requestAPI; // = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                 // the requestAPI requires us to tell it how much data to return so we use a NSDictionary to set the count
                 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                 [parameters setObject:@"100" forKey:@"count"];
                 
                 requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
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
                             NSDictionary *firstTweet = _array[0];
                             NSLog(@"first Tweet : %@", firstTweet[@"text"]);
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
    
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1.5];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_array count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFFTweetCellMin *cell = (MFFTweetCellMin *) [self.tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
    NSDictionary *tweet = _array[indexPath.row];
    cell.username.text = [tweet valueForKeyPath:@"user.screen_name"];
    UIFontDescriptor *bodyFontDesciptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *boldBodyFontDescriptor = [bodyFontDesciptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    cell.username.font = [UIFont fontWithDescriptor:boldBodyFontDescriptor size:12.0];
    //cell.username.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    cell.tweet.text = tweet[@"text"];
    // following 2 lines are supposed to make the text start at top left
    cell.tweet.numberOfLines = 0;
    [cell.tweet sizeToFit];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
