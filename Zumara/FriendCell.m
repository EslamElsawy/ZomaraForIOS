//
//  FriendCell.m
//  Zumara
//
//  Created by Muhammad Hassan Nasr on 6/25/14.
//
//

#import "FriendCell.h"

@implementation FriendCell

-  (IBAction) alarmButtonTouched{
    self.alarmButton.enabled = NO;
    
    [self performSelector:@selector(enableAlarmButton) withObject:nil afterDelay:60];
    
    [self.delegate alarmButtonTouchedOnCell:self];
}

- (void) enableAlarmButton{
    self.alarmButton.enabled = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    self.nameLabel.text = self.zumaraFriend[FACEBOOK_NAME];
    self.profilePictureView.profileID = self.zumaraFriend[FACEBOOK_ID];
    self.profilePictureView.layer.cornerRadius = 38;
}

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableAlarmButton) object:nil];
}

@end
