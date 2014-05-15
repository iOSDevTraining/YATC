//
//  MFFProfileViewController.m
//  TwitterTimeline
//
//  Created by Brian Preston on 4/7/14.
//  Copyright (c) 2014 MobileFunForge. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>


#import "MFFProfileViewController.h"


@implementation MFFProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self twitterProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) twitterProfile {
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
                 NSString *username = twitterAccount.username;
                 // API call that returns a user's profile
                 NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json" ];
                 // this is where we are getting the data using SLRequest
                 SLRequest *profile = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", username], @"screen_name", @"-1", @"cursor", nil]];
                 profile.account = twitterAccount;
                 // the postRequest: method call now accesses the NSData object returned
                 [profile performRequestWithHandler:^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error) {
                     
                     NSDictionary *profileData = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&error];
                     if (profileData.count > 0) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSString *profileImageURL = [profileData objectForKey:@"profile_image_url"];
                             NSURL *imageUrl = [[NSURL alloc] initWithString:profileImageURL];
                             UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
                             _profileImageView.image = profileImage;
                             NSNumber *numFollowers = [profileData objectForKey:@"followers_count"];
                             _numFollowers.text = [numFollowers stringValue];
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


@end
