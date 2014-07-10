//
//  AboutViewController.h
//  Zumara
//
//  Created by Muhammad Hassan Nasr on 7/9/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIButton *logoutButton;
@property (strong,nonatomic) IBOutlet UISegmentedControl *languageSegment;

- (IBAction)logoutButtonAction:(id)sender;
- (IBAction)languageSegmentAction:(id)sender;

- (IBAction)facebookButtonAction:(id)sender;
- (IBAction)emailButtonAction:(id)sender;

@end
