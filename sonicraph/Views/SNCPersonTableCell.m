//
//  SNCPersonTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/6/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCPersonTableCell.h"
#import "SNCAPIManager.h"
#import "Configurations.h"
#import "UIButton+StateProperties.h"
#import "AuthenticationManager.h"

@implementation SNCPersonTableCell

- (CGRect) profileImageViewFrame
{
    return CGRectMake(10.0, 8.0, 49.0, 49.0);
}

- (CGRect) fullnameLabelFrame
{
    return CGRectMake(68.0, 5.0, 150.0, 18.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(68.0, 26.0, 150.0, 16.0);
}

- (CGRect) locationLabelFrame
{
    return CGRectMake(76.0, 45.0, 320.0 - 60.0, 16.0);
}

- (CGRect) locationImageViewFrame
{
    return CGRectMake(64.0, 48.0, 12.0, 12.0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void) initViews
{
    
    self.profileImageView = [[FadingImageView alloc] initWithFrame:[self profileImageViewFrame]];
    [self.profileImageView setFrame:[self profileImageViewFrame]];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    [self.profileImageView.layer setDrawsAsynchronously:YES];
    [self.profileImageView setUserInteractionEnabled:YES];
    [self.profileImageView setImage:UserPlaceholderImage];
    [self.contentView addSubview:self.profileImageView];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    [self.contentView addSubview:self.fullnameLabel];
    [self.fullnameLabel setTextColor:FullnameTextColor];
    self.fullnameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setTextColor:[UIColor lightGrayColor]];
    [self.usernameLabel setUserInteractionEnabled:YES];
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:self.usernameLabel];
    
    self.locationLabel = [[UILabel alloc] initWithFrame:[self locationLabelFrame]];
    [self.contentView addSubview:self.locationLabel];
    [self.locationLabel setTextColor:[UIColor lightGrayColor]];
    self.locationLabel.font = [UIFont systemFontOfSize:10.0];
    
    self.locationImageView = [[UIImageView alloc] initWithFrame:[self locationImageViewFrame]];
    [self.contentView addSubview:self.locationImageView];
    [self.locationImageView setContentMode:UIViewContentModeScaleAspectFit];
    self.locationImageView.image = [UIImage imageNamed:@"location.png"];
    
    UIGestureRecognizer* tapGesture;
//    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
//    [self.usernameLabel addGestureRecognizer:tapGesture];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.profileImageView addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userUpdated:)
     name:NotificationUpdateViewForUser
     object:nil];
}

- (void) userUpdated:(NSNotification*)notification
{
    User* user = notification.object;
//    if([self.user.userId isEqualToString:user.userId])
//    {
//        [self.user updateWithUser:user];
//        [self configureViews];
//    }
    if(self.user == user)
    {
        [self configureViews];
    }
}

- (void) tapGesture
{
    [self.delegate openProfileForUser:self.user];
}

- (void) setUser:(User *)user
{
    _user = user;
    [self configureViews];
}

- (void)configureViews
{
    if(self.user){
        [self.usernameLabel setText:[@"@" stringByAppendingString:self.user.username]];
        [self.fullnameLabel setText:self.user.fullName];
        [self.locationLabel setText:self.user.location];
        self.locationImageView.hidden = !self.user.location || [self.user.location isEqualToString:@""];
        if(self.profileImageView.image != self.user.thumbnailProfileImage)
        {
            [self.user getThumbnailProfileImageWithCompletionBlock:^(UIImage* image,User* user) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(image && self.user == user){
                        [self.profileImageView setImageWithAnimation:image];
                    }
                });
            }];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [self.profileImageView setImage:UserPlaceholderImage];
    [self.usernameLabel setText:@""];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}
@end

@implementation SNCPersonFollowableTableCell

- (CGRect) followContentFrame
{
    return CGRectMake(320.0-88.0, 0.0, 88.0, PersonTableCellHeight);
}

- (CGRect) followButtonFrame
{
    return CGRectMake(0.0, 18.0, 80.0, 30.0);
}

- (CGRect) unfollowButtonFrame
{
    return CGRectMake(40.0, 18.0, 40.0, 30.0);
}
- (void) initViews{
    [super initViews];
    self.followContent = [[UIView alloc] initWithFrame:[self followContentFrame]];
    [self.followContent setUserInteractionEnabled:YES];
    [self.contentView addSubview:self.followContent];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.followButton setFrame:[self followButtonFrame]];
    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.followButton setClipsToBounds:YES];
    [self.followButton setBackgroundImageWithColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.followButton setBackgroundImageWithColor:MainThemeColor forState:UIControlStateHighlighted];
    [self.followButton setTitleColor:MainThemeColor forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.followButton.layer setBorderWidth:1.0];
    [self.followButton.layer setBorderColor:MainThemeColor.CGColor];
    [self.followButton.layer setCornerRadius:5.0];
    [self.followButton.layer setOpaque:YES];
    [self.followButton.layer setShouldRasterize:YES];
    [self.followButton.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [self.followButton.layer setDrawsAsynchronously:YES];
    [self.followContent addSubview:self.followButton];

    self.unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.unfollowButton setFrame:[self unfollowButtonFrame]];
    [self.unfollowButton setImage:[UIImage imageNamed:@"Following.png"] forState:UIControlStateNormal];
    [self.unfollowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.followContent addSubview:self.unfollowButton];
    
    [self.followButton setHidden:YES];
    [self.unfollowButton setHidden:YES];
    
    [self.followButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.unfollowButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUser:(User *)user
{
    [super setUser:user];
}

- (void) configureViews
{
    [super configureViews];
    if([self.user.userId isEqualToString:[[[AuthenticationManager sharedInstance] authenticatedUser] userId]])
    {
        [self.followContent setHidden:YES];
    }
    else
    {
        [self.followContent setHidden:NO];
        if(self.user.isBeingFollowed){
            [self.unfollowButton setHidden:NO];
            [self.followButton setHidden:YES];
        }else {
            [self.unfollowButton setHidden:YES];
            [self.followButton setHidden:NO];
        }
        
    }
    
}

- (void) buttonTapped:(UIButton*)button
{
    if(button == self.followButton){
        self.user.isBeingFollowed = YES;
        [SNCAPIManager
         followUser:self.user
         withCompletionBlock:^(BOOL successful)
         {
             [self.delegate followUser:self.user];
             
             [self.user fireUserUpdatedForViewNotification];
         } andErrorBlock:^(NSError *error) {
             self.user.isBeingFollowed = NO;
             [self configureViews];
         }];
        
        [self configureViews];
    } else if(self.unfollowButton){
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:self.user.fullName delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles: nil];
        [actionSheet showInView:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self confirmUnfollow];
    }
}

- (void) confirmUnfollow
{
    self.user.isBeingFollowed = NO;
    [SNCAPIManager
     unfollowUser:self.user
     withCompletionBlock:^(BOOL successful)
     {
         [self.user fireUserUpdatedForViewNotification];
         [self.delegate unfollowUser:self.user];
     }
     andErrorBlock:^(NSError *error)
     {
         self.user.isBeingFollowed = YES;
         [self configureViews];
     }
    ];
    [self configureViews];
}


@end








