//
//  FriendsTableViewController.m
//  Zumara
//
//  Created by Muhammad Hassan Nasr on 6/10/14.
//
//

#import "FriendsTableViewController.h"
#import <Parse/Parse.h>
#define MAX_USER_NAME 15

@implementation FriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE_5) {
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-568h@2x"]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    }
    
    // Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    refreshControl.layer.zPosition += 1;

    self.awakeButton.enabled = YES;
    [self refresh];
    
}

- (void) refresh{
    [[FBRequest requestForMe] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {

        if (error) {
            NSLog(@"Uh oh. An error occurred: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Loadings Friends",nil) message:@"Try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss",nil), nil];
            [alert show];
            [self.refreshControl endRefreshing];
        }else{
            FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"/me/friends"];
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result,NSError *error) {
                if(!error){
                    NSArray *data = [result objectForKey:@"data"];                    
                    [self filterAwakenFriends:data];
                }else{
                    NSLog(@"Uh oh. An error occurred: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Loadings Friends",nil) message:NSLocalizedString(@"Try again later",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss",nil), nil];
                    [alert show];
                    [self.refreshControl endRefreshing];
                }
            }];
        }
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIEND_CELL_ID" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.zumaraFriend = self.friends[indexPath.row];
   
    return cell;
}


- (void) alarmButtonTouchedOnCell:(UITableViewCell*) cell{

    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    PFUser * zumaraFriend = self.friends[indexPath.row];
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:FACEBOOK_ID equalTo:zumaraFriend[FACEBOOK_ID]];
    
    NSString * senderName =  [PFUser currentUser][FACEBOOK_NAME];
    if(senderName.length > MAX_USER_NAME){    //trim user name so it can fit in iOS push notification
        senderName = [senderName substringToIndex:senderName.length-(senderName.length-MAX_USER_NAME)];
    }
    
    NSString * senderID =  [PFUser currentUser][FACEBOOK_ID];
    NSString * alertMessage = [NSString stringWithFormat:NSLocalizedString(@"Prayer is better than sleep",nil),senderName];

    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          alertMessage, @"alert",
                          @"Increment", @"badge",
                          @"fajr.caf", @"sound",
                          @"alarm",@"type",
                          @"com.badit.zomara.UPDATE_STATUS",@"action",
                          senderID,@"fromId",
                          senderName,@"fromUser",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
   
}

- (void)awake:(id)sender{
    
    [[PFUser currentUser] setObject:[NSDate date] forKey:LAST_AWAKEN_AT];
    [[PFUser currentUser] saveInBackground];
    
    self.awakeButton.enabled = NO;

}

- (void)filterAwakenFriends:(NSArray*)allFriends{
    NSArray * friendsFacebookIDs = [allFriends valueForKey:@"id"];
    //Create query for all Post object by the current user
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:FACEBOOK_ID containedIn:friendsFacebookIDs];
    
    // Run the query
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Save results and update the table
            NSMutableArray * awakenFriends = [NSMutableArray array];
            for(PFUser * friend in objects){
                if([self isFriendSleep:friend]){
                    [awakenFriends addObject:friend];
                }
            }
            self.friends = awakenFriends;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (BOOL) isFriendSleep:(PFUser*) friend{
    NSDate * lastAwakenAt = friend[LAST_AWAKEN_AT];
    if(!lastAwakenAt){
        return YES;
    }
    
    NSInteger hoursSinceBeenAwaken = [[NSDate date]timeIntervalSinceDate:lastAwakenAt]/3600;
    if(hoursSinceBeenAwaken>4){
        return YES;
    }
    
    return NO;
}

@end
