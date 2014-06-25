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


@end
