//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "FriendsTableViewController.h"

#define SHOW_FRIENDS_SEGUE @"show_friends"

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE_5) {
        self.backgroundImageView.image = [UIImage imageNamed:@"Default-568h@2x"];
    }
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showFriendsViewController];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Login mehtods

- (void)showFriendsViewController {

    [self performSegueWithIdentifier:SHOW_FRIENDS_SEGUE sender:self];

}


/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location",@"user_friends"];
    
    // Login PFUser using facebook
    
    self.facebookIconButton.enabled = NO;
    self.loginButton.enabled = NO;
    //self.loginButton.titleLabel.text = @"Logout";
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished

    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        self.facebookIconButton.enabled = YES;
        self.loginButton.enabled = YES;

        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }else{
            [self updateUserDataOnParse];
            [self showFriendsViewController];

        }

    }];
    
}


- (void) updateUserDataOnParse{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
           
            NSString *facebookID = userData[@"id"];
            NSString *facebookName = userData[@"name"];
            NSString *facebookLink = userData[@"link"];

            [[PFUser currentUser] setObject:facebookID forKey:FACEBOOK_ID];
            [[PFUser currentUser] setObject:facebookName forKey:FACEBOOK_NAME];
            [[PFUser currentUser] setObject:facebookLink forKey:FACEBOOK_LINK];
            [[PFUser currentUser] saveInBackground];
            
            [[PFInstallation currentInstallation] setObject:facebookID forKey:FACEBOOK_ID];
            [[PFInstallation currentInstallation] setObject:facebookName forKey:FACEBOOK_NAME];
            [[PFInstallation currentInstallation] saveInBackground];
        }else{
            NSLog(@"Error update user data on parse %@",[error description]);
        }
    }];
}
     


@end
