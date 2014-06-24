//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import "UserDetailsViewController.h"
#import <Parse/Parse.h>
#import "FriendsTableViewController.h"

#define show_friend_segue @"show_friends"

@interface LoginViewController()
@property (nonatomic, strong) FBFriendPickerViewController *friendPickerController;

@end

@implementation LoginViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Zomara App";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showFriendsViewController];
    }
}


#pragma mark - Login mehtods

- (void)showFriendsViewController {

//    self.friendPickerController = [[FBFriendPickerViewController alloc] init];
//    self.friendPickerController.title = @"Wake Your Friends Up";
//    self.friendPickerController.delegate = self;
//    [self.friendPickerController loadData];
//    [self.friendPickerController clearSelection];
//    
//    [self.navigationController pushViewController:self.friendPickerController animated:YES];

    [[FBRequest requestForMe] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        if (error) {
            NSLog(@"Uh oh. An error occurred: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch User Data Error" message:@"Try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }else{
            FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"/me/friends"];
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result,NSError *error) {              
                if(!error){
                    NSArray *data = [result objectForKey:@"data"];

                    self.friends = data;
                    [self performSegueWithIdentifier:show_friend_segue sender:self];

                }else{
                    NSLog(@"Uh oh. An error occurred: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch Friends Error" message:@"Try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
            }];
        }
    }];

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:show_friend_segue]) {
        FriendsTableViewController * friendsTableViewController = [segue destinationViewController];
        friendsTableViewController.friends = self.friends;
    }
}

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location",@"user_friends"];
    
    // Login PFUser using facebook
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
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
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
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

            [[PFUser currentUser] setObject:facebookID forKey:@"facebookId"];
            [[PFUser currentUser] setObject:facebookName forKey:@"facebookName"];
            [[PFUser currentUser] setObject:facebookLink forKey:@"facebookLink"];
            [[PFUser currentUser] saveInBackground];
            
            [[PFInstallation currentInstallation] setObject:facebookID forKey:@"facebookId"];
            [[PFInstallation currentInstallation] setObject:facebookName forKey:@"facebookName"];
            [[PFInstallation currentInstallation] saveInBackground];
        }else{
            NSLog(@"Error update user data on parse %@",[error description]);
        }
    }];
}
     


@end
