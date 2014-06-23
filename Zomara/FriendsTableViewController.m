//
//  FriendsTableViewController.m
//  Zomara
//
//  Created by Muhammad Hassan Nasr on 6/10/14.
//
//

#import "FriendsTableViewController.h"
#import <Parse/Parse.h>

@interface FriendsTableViewController ()
@property NSArray * zomaraFriends;
@end

@implementation FriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PFQuery *query = [PFUser query];
    
    /*ParseQuery<ParseUser> query = ParseUser.getQuery();
    query.whereContainedIn("facebookId", ids);
    try {
        List<ParseUser> matchedUsers = query.find();
        for (int i = 0; i < matchedUsers.size(); i++) {
            ParseUser curr = matchedUsers.get(i);
            String currId = curr.getString("facebookId");
            String currName = curr.getString("facebookName");
     */
    
    NSArray * ids = [self.allFacebookFriends valueForKey:@"id"];
    [query whereKey:@"facebookId" containedIn:ids];
    self.zomaraFriends = [query findObjects];
    [self.tableView reloadData];
    NSLog(@"Zomara Friends %@",self.zomaraFriends);
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
    return [self.zomaraFriends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIEND_CELL_ID" forIndexPath:indexPath];
    
    // Configure the cell...
    PFUser * zomaraFriend = self.zomaraFriends[indexPath.row];
    NSString * name = zomaraFriend[@"facebookName"];
    cell.textLabel.text = name;
    
    return cell;
}



- (IBAction)wake:(id)sender {
    UIButton * wakeButton = sender;
    //TODO: Make a friend cell with delegate to get cell easily
    UITableViewCell * cell = (UITableViewCell *)wakeButton.superview.superview.superview;
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    PFUser * zomaraFriend = self.zomaraFriends[indexPath.row];
    NSString * name = zomaraFriend[@"facebookName"];
    NSLog(@"wake %@",name);
    
    // Create our Installation query
    //TODO: send to PFUser or PFInstallation??
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"facebookId" equalTo:zomaraFriend[@"facebookId"]];
    
    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                   withMessage:@"Asalatu khyron mena anoouummm!!!"];
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
