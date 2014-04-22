//
//  MFFHomeViewController.m
//  TwitterTimeline
//
//  Created by Brian Preston on 3/29/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "MFFHomeViewController.h"
#import "MFFTweetCell.h"
#import "MFFProfileViewHeaderController.h"
#import "MFFTwitterTableViewController.h"

@interface MFFHomeViewController ()

@property (strong, nonatomic) NSArray *array;

@end

@implementation MFFHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if(_userId) {
        [self twitterUserProfile];
    } else {
        [self twitterHome];
    }
    
    UIImage *image = [UIImage imageNamed:@"newTweetSmall"];
//    UIImage *image = [UIImage imageWithContentsOfFile:@"newTweetSmall"];
    // [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 40, 80) resizingMode:UIImageResizingModeStretch];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(newTweet)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(newTweet)];
    
    // uncomment these lines if you want the profile view on the top of the tweets
//    NSBundle *appBundle = [NSBundle mainBundle];
//    
//    MFFProfileViewHeaderController *profileView = [[MFFProfileViewHeaderController alloc] initWithNibName:@"MFFProfileViewHeaderController" bundle:appBundle];
//    
//    self.tableView.tableHeaderView = profileView.view;
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
                 if (_userId) {
                     [parameters setObject:_userId forKey:@"user_id"];
                     requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                 } else {
                     requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
                     [parameters setObject:@"1" forKey:@"include_entities"];
                 }
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
}

#pragma mark Table View Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Returns the number of rows for the table view using the array instance variable
    return [_array count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    // Creates each cell for the table view
    //    static NSString *cellID = @"CELLID";
    //    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    //    }
    //    // Creates an NSDictionary that holds the user's posts and then loads the data into each cellof the table's view
    //    NSDictionary *tweet = _array[indexPath.row];
    //    cell.textLabel.text = tweet[@"text"];
    //    return cell;
    
    MFFTweetCell *cell = (MFFTweetCell *) [self.tableView dequeueReusableCellWithIdentifier:@"TwitterCell"];
    NSDictionary *tweet = _array[indexPath.row];
    cell.name.text = [tweet valueForKeyPath:@"user.name"];
    
    UIFontDescriptor *bodyFontDesciptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *boldBodyFontDescriptor = [bodyFontDesciptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    cell.username.font = [UIFont fontWithDescriptor:boldBodyFontDescriptor size:12.0];
    cell.username.text = [tweet valueForKeyPath:@"user.screen_name"];
    
    cell.tweet.text = tweet[@"text"];
    cell.tweet.numberOfLines = 0;
    [cell.tweet sizeToFit];
    
    // image takes a bit more
    NSString *profileImageURL = [tweet valueForKeyPath:@"user.profile_image_url"];
    NSURL *imageUrl = [[NSURL alloc] initWithString:profileImageURL];
    UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    cell.profileImageView.image = profileImage;
    
    // calculate how long ago
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:currentLocale];
    // current format from twitter is 'Tue Aug 28 21:16:23 +0000 2012'
    [df setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];

    NSString *tweetDateString = tweet[@"created_at"];
    NSDate *tweetDate = [df dateFromString:tweetDateString];
    NSDate *now = [[NSDate alloc] init];
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:tweetDate  toDate:now  options:0];

    NSString *timeElapsed;
    if(breakdownInfo.day > 0) {
        timeElapsed = [NSString stringWithFormat:@"%dd", [breakdownInfo day] ];
    } else if (breakdownInfo.hour > 0) {
        timeElapsed = [NSString stringWithFormat:@"%dh", [breakdownInfo hour] ];
    } else if ([breakdownInfo minute] > 0) {
        timeElapsed = [NSString stringWithFormat:@"%dm", [breakdownInfo minute] ];
    } else if ([breakdownInfo second] > 0) {
        timeElapsed = [NSString stringWithFormat:@"%ds", [breakdownInfo second] ];
    }
    
    cell.time.text = timeElapsed;
                   
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // when a user selects a row this will de-select the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *tweet = _array[indexPath.row];
    NSNumber *userId = [tweet valueForKeyPath:@"user.id"];
    NSString *userName = [tweet valueForKeyPath:@"user.screen_name"];
    NSLog(@"trying to get tweets for %@", userName);
    [self viewUserProfile:userId screenName:userName];
}

-(void) viewUserProfile:(NSNumber *)userIdIn screenName:(NSString *) screenNameIn {
    MFFTwitterTableViewController *profileView = [[MFFTwitterTableViewController alloc] init];
    profileView.title = screenNameIn;
    profileView.userId = userIdIn;
    profileView.screenName = screenNameIn;
    [[self navigationController] pushViewController:profileView animated:YES];
}

@end
