//
//  FriendCell.m
//  Zomara
//
//  Created by Muhammad Hassan Nasr on 6/25/14.
//
//

#import "FriendCell.h"

@implementation FriendCell

- (void) alarmButtonTouched{
    [self.delegate alarmButtonTouchedOnCell:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];

    self.nameLabel.text = self.zomaraFriend[FACEBOOK_NAME];
    self.profilePictureView.profileID = self.zomaraFriend[FACEBOOK_ID];
    self.profilePictureView.layer.cornerRadius = 38;
}

@end
