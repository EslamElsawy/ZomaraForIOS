//
//  FriendsTableViewController.h
//  iQezny
//
//  Created by Muhammad Hassan Nasr on 6/10/14.
//
//

#import <UIKit/UIKit.h>
#import "FriendCell.h"

@interface FriendsTableViewController : UITableViewController<FriendCellDelegate>

@property NSArray * friends;
@property(strong,nonatomic) IBOutlet UIBarButtonItem * awakeButton;

- (IBAction)awake:(id)sender;

@end
