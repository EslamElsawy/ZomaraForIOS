//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "FriendsTableViewController.h"

#define SHOW_FRIENDS_SEGUE @"show_friends"

@interface LoginViewController ()
@property (atomic) BOOL isLoggedIn;
@end

@implementation LoginViewController


#pragma mark - UIViewController

- (void)updateLanguageSegment {
    NSArray *deviceLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    if([deviceLanguages count]){
        if([[deviceLanguages objectAtIndex:0] isEqualToString:@"ar"]){
            self.languageSegment.selectedSegmentIndex = 0;
        }else{
            self.languageSegment.selectedSegmentIndex = 1;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE_5) {
        self.backgroundImageView.image = [UIImage imageNamed:@"Default-568h@2x"];
    }
    
    // Check if user is cached and linked to Facebook, if so, bypass login    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self loginSucceeded];
    }
    
    [self updateLanguageSegment];
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


- (void)loginSucceeded {
    self.isLoggedIn = YES;
    self.loginButton.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Signout, %@",nil),[PFUser currentUser][FACEBOOK_NAME]];
    [self updateUserDataOnParse];
    [self showFriendsViewController];
}

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    
    if(self.isLoggedIn){
        [self logout];
        return;
    }
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location",@"user_friends"];
    
    // Login PFUser using facebook
    
    self.facebookIconButton.enabled = NO;
    self.loginButton.enabled = NO;
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished

    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        self.facebookIconButton.enabled = YES;
        self.loginButton.enabled = YES;

        if (!user) {
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log In Error",nil) message:NSLocalizedString(@"The Facebook login was cancelled by the user.",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss",nil), nil];
                [alert show];
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log In Error",nil) message:NSLocalizedString(@"Please check your internet connection",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss",nil), nil];
                [alert show];
            }
        }else{
            [self loginSucceeded];
        }

    }];
    
}

- (void) logout{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        self.isLoggedIn = NO;
        self.loginButton.titleLabel.text = NSLocalizedString(@"Sign in with Facebook",nil);
    }
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


- (IBAction)languageSegmentAction:(id)sender{

    NSString * alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Change Language Warning Message", @""),NSLocalizedString(@"New Language", @"")];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Change Language Dialog Title", @"") message:alertMessage
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"OK", @"") ,nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){//OK
        if(self.languageSegment.selectedSegmentIndex == 0){
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"ar", nil] forKey:@"AppleLanguages"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"eg", nil] forKey:@"AppleLanguages"];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
        exit(0);
    }else{
        [self updateLanguageSegment];
    }
}


-(IBAction)goToBadrIT:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.badrit.com"]];
}

@end
