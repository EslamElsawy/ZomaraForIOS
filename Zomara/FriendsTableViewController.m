//
//  FriendsTableViewController.m
//  Zomara
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
                    NSLog(@"Zomara Friends %@",self.friends);
                    [self.tableView reloadData];
                    
                }else{
                    NSLog(@"Uh oh. An error occurred: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetch Friends Error" message:@"Try again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
            }];
        }
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIEND_CELL_ID" forIndexPath:indexPath];
    
    // Configure the cell...
    PFUser * zomaraFriend = self.friends[indexPath.row];
    NSString * name = zomaraFriend[@"name"];
    cell.nameLabel.text = name;
    NSString * id = zomaraFriend[@"id"];
    cell.profilePictureView.profileID = id;
    
    return cell;
}


- (void) alarmButtonTouchedOnCell:(UITableViewCell*) cell{

    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    PFUser * zomaraFriend = self.friends[indexPath.row];
    NSString * name = zomaraFriend[@"name"];
    NSLog(@"wake %@",name);
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"facebookId" equalTo:zomaraFriend[@"id"]];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"الصلاة خير من النوم", @"alert",
                          @"Increment", @"badge",
                          @"fajr.caf", @"sound",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
}


@end
