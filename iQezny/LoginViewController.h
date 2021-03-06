//
//  Copyright (c) 2013 Parse. All rights reserved.

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController<FBFriendPickerDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UIButton *facebookIconButton;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;


- (IBAction)loginButtonAction:(id)sender;

@end
