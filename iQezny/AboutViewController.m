//
//  AboutViewController.m
//  iQezny
//
//  Created by Muhammad Hassan Nasr on 7/9/14.
//
//

#import "AboutViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>


@implementation AboutViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE_5) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-568h@2x"]];
    }else{
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    }

    [self updateLanguageSegment];
    
    NSString * facebookName = [PFUser currentUser][FACEBOOK_NAME];
    if(facebookName){
        self.logoutButton.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Log Out, %@",nil),facebookName];
    }


}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) logoutButtonAction:(id)sender{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        [self.presentingViewController
         dismissViewControllerAnimated:YES
         completion:nil];
    }
}

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

-(IBAction)doneButtonAction:(id)sender{
    [self.presentingViewController
     dismissViewControllerAnimated:YES
     completion:nil];
}

-(IBAction)facebookButtonAction:(id)sender{
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: @"fb://profile/597183003729785"]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"fb://profile/597183003729785"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://facebook.com/iQezny"]];
    }
    
}

- (IBAction)emailButtonAction:(id)sender {

    NSArray *toRecipents = [NSArray arrayWithObject:@"iqezny@muhammadhassannasr.com"];
    
    MFMailComposeViewController *MailComposeViewController = [[MFMailComposeViewController alloc] init];
    MailComposeViewController.mailComposeDelegate = self;
    [MailComposeViewController setSubject:@""];
    [MailComposeViewController setMessageBody:@"" isHTML:NO];
    [MailComposeViewController setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:MailComposeViewController animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
