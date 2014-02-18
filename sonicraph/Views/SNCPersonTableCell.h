//
//  SNCPersonTableCell.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TypeDefs.h"

#define SNCPersonTableCellIdentifier @"SNCPersonTableCellIdentifier"

@class SNCPersonTableCell;
@class Sonic;
@protocol SNCPersonFollowableTableCellProtocol

- (void) followUser:(User*)user;
- (void) unfollowUser:(User*)user;

@end


@interface SNCPersonTableCell : UITableViewCell

@property (nonatomic) User* user;

@property UILabel* usernameLabel;
@property UIImageView* profileImageView;
@property UILabel* fullnameLabel;
@property UILabel* locationLabel;
@property UIImageView* locationImageView;

@property id<OpenProfileProtocol> delegate;

- (void) initViews;
- (void) configureViews;

@end

@interface SNCPersonFollowableTableCell : SNCPersonTableCell <UIActionSheetDelegate>

@property UIView* followContent;

@property UIButton* followButton;

@property UIButton* unfollowButton;

@property id<SNCPersonFollowableTableCellProtocol,OpenProfileProtocol> delegate;

@end