//
//  FriendsTableViewController.m
//  Zumara
//
//  Created by Muhammad Hassan Nasr on 6/10/14.
//
//

#import "FriendsTableViewController.h"
#import <Parse/Parse.h>

@implementation FriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    self.tableView.backgroundView = background;
    
    // Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    refreshControl.layer.zPosition += 1;

    [self refresh];
    
}

- (void) refresh{
    [[FBRequest requestForMe] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {

        if (error) {
            NSLog(@"Uh oh. An error occurred: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch User Data Error" message:@"Try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch Friends Error" message:@"Try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
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
    NSString * name = zumaraFriend[FACEBOOK_NAME];
    NSLog(@"wake %@",name);
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:FACEBOOK_ID equalTo:zumaraFriend[FACEBOOK_ID]];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"الصلاة خير من النوم", @"alert",
                          @"Increment", @"badge",
                          @"fajr.caf", @"sound",                                                              @"alarm",@"type",
                          zumaraFriend[FACEBOOK_ID],@"fromId",
                          zumaraFriend[FACEBOOK_NAME],@"fromUser",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
}

- (void)awake:(id)sender{
    
    [[PFUser currentUser] setObject:[NSDate date] forKey:LAST_AWAKEN_AT];
    [[PFUser currentUser] saveInBackground];

}


- (void)filterAwakenFriends:(NSArray*)allFriends
{
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
                
                NSDate * lastAwakenAt = friend[LAST_AWAKEN_AT];
                if(!lastAwakenAt){
                    [awakenFriends addObject:friend];
                }
                
                NSInteger hoursBeenAwaken = [[NSDate date]timeIntervalSinceDate:lastAwakenAt]/3600;
                if(hoursBeenAwaken>4){
                    [awakenFriends addObject:friend];
                }
            }
            self.friends = awakenFriends;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}
@end
