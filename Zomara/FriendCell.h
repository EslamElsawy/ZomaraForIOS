//
//  FriendCell.h
//  Zomara
//
//  Created by Muhammad Hassan Nasr on 6/25/14.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@protocol FriendCellDelegate

- (void) alarmButtonTouchedOnCell:(UITableViewCell*) cell;

@end

@interface FriendCell : UITableViewCell

@property(strong,nonatomic) IBOutlet FBProfilePictureView * profilePictureView;
@property(strong,nonatomic) IBOutlet UILabel * nameLabel;
@property(weak,nonatomic)  IBOutlet id<FriendCellDelegate> delegate;

@property(strong) PFUser * zomaraFriend ;

-  (IBAction) alarmButtonTouched;

@end
