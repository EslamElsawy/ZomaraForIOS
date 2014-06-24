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
    self.title = @"Facebook Profile";
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showPickFriendPickerViewController];

       // [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:NO];
    }
}


#pragma mark - Login mehtods

- (void)showPickFriendPickerViewController {

//    self.friendPickerController = [[FBFriendPickerViewController alloc] init];
//    self.friendPickerController.title = @"Pick Friends";
//    self.friendPickerController.delegate = self;
//    [self.friendPickerController loadData];
//    [self.friendPickerController clearSelection];
//    
//    [self.navigationController pushViewController:self.friendPickerController animated:YES];

    [[FBRequest requestForMe] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        if (error) {
            //Throws the code 100 error here
            //completionBlock(nil, error);
        }else{
            FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"/me/friends"];
          //  FBRequest* friendsRequest = [FBRequest requestForMyFriends];
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result,NSError *error) {
              
                {
                    NSArray *data = [result objectForKey:@"data"];
                    

                    self.friends = data;
                    [self performSegueWithIdentifier:show_friend_segue sender:self];

                    /*for(NSDictionary * friendDict in friendJSONs)
                    {
                        SocialProfile *friend=[[SocialProfile alloc] initWithDictionary:friendDict socialMedia:kSocialMediaFacebook];
                        [friends addObject:friend];
                    }*/
                  //  completionBlock(friends, nil);
                }
            }];
        }
    }];
//
//   /* [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            NSArray *data = [result objectForKey:@"data"];
//            self.friends = data;
//            [self performSegueWithIdentifier:show_friend_segue sender:self];
//            
//        } else {
//            NSLog(@"Uh oh. An error occurred: %@", error);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch Friends Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
//            [alert show];
//            //      [self facebookRequestDidFailWithError:error];
//        }
//    }];*/
////    [self.navigationController pushViewController:self.friendPickerController animated:YES];
}

- (BOOL)retrieveFacebookFriendsForProfileId:(NSString *)fbProfileId completionBlock:(void (^)(NSArray *, NSError *))completionBlock
{
    
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      if (error) {
                                          
                                          NSLog(@"Error");
                                      } else if (session.isOpen) {
                                          
                                          
                                      }
                                  }];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:show_friend_segue]) {
        FriendsTableViewController * friendsTableViewController = [segue destinationViewController];
        friendsTableViewController.allFacebookFriends = self.friends;        
    }
}

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"user_friends"];
    
    // Login PFUser using facebook
    NSLog(@"compatible with old API v 1.0 %d",[FBSettings isPlatformCompatibilityEnabled]);
          
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }else{
            [self updateUser];
            [self showPickFriendPickerViewController];

        }
        /*else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        } else {
            NSLog(@"User with facebook logged in!");
            [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        }*/
     
     

    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}


- (void) updateUser{
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] setObject:facebookID forKey:@"facebookId"];
            [[PFUser currentUser] saveInBackground];
            [[PFInstallation currentInstallation] setObject:facebookID forKey:@"facebookId"];
            [[PFInstallation currentInstallation] saveInBackground];
        }
    }];
}
     
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    NSLog(@"Selected users %@",text);
    
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id <FBGraphUser>)user{
 //   [PFUser currentUser].user.Friends
    //self.friendPickerController.
    return YES;
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
}



@end
