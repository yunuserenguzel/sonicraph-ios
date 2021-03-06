//
//  SNCNotificationCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/26/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCNotificationCell.h"
#import "NSDate+NVTimeAgo.h"
#import <QuartzCore/QuartzCore.h>

@implementation SNCNotificationCell

- (CGRect) notificationTypeImageViewFrame
{
    return CGRectMake(275.0, 5.0, 30.0, NotificationTableCellHeight);
}

- (CGRect) profileImageViewFrame
{
    return CGRectMake(10.0, 8.0 , 49.0, 49.0);
}

- (CGRect) fullnameLabelFrame
{
    return CGRectMake(68.0, 5.0, 150.0, 18.0);
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(68.0, 26.0, 150.0, 16.0);
}

- (CGRect) createAtLabelFrame
{
    return CGRectMake(255.0, 5.0, 55.0, 18.0);
}

- (CGRect) notificationTextLabelFrame
{
    return CGRectMake(68.0, 42.0, 210.0, 18.0);
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
    self.notificationTypeImageView = [[UIImageView alloc] initWithFrame:[self notificationTypeImageViewFrame]];
    [self.contentView addSubview:self.notificationTypeImageView];
    [self.notificationTypeImageView setContentMode:UIViewContentModeCenter];
    
    self.profileImageView = [[FadingImageView alloc] initWithFrame:[self profileImageViewFrame]];
    [self.contentView addSubview:self.profileImageView];
    self.profileImageView.layer.cornerRadius = [self profileImageViewFrame].size.height * 0.5;
    [self.profileImageView setClipsToBounds:YES];
    
    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    self.fullnameLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.fullnameLabel.textColor = FullnameTextColor;
    [self.contentView addSubview:self.fullnameLabel];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setTextColor:[UIColor lightGrayColor]];
    [self.usernameLabel setUserInteractionEnabled:YES];
    self.usernameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:self.usernameLabel];
    
    self.notificationTextLabel = [[UILabel alloc] initWithFrame:[self notificationTextLabelFrame]];
    [self.contentView addSubview:self.notificationTextLabel];
    self.notificationTextLabel.numberOfLines = 0;
    self.notificationTextLabel.font = [self.notificationTextLabel.font fontWithSize:10.0];
    self.notificationTextLabel.textColor = [UIColor grayColor];
    
    self.createdAtLabel = [[UILabel alloc] initWithFrame:[self createAtLabelFrame]];
    [self.contentView addSubview:self.createdAtLabel];
    self.createdAtLabel.textColor = [UIColor lightGrayColor];
    self.createdAtLabel.textAlignment = NSTextAlignmentRight;
    self.createdAtLabel.font = [UIFont boldSystemFontOfSize:10.0];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setNotification:(Notification *)notification
{
    _notification = notification;
    [self configureViews];
}

- (void) configureViews
{
    self.fullnameLabel.text = self.notification.byUser.fullName;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@",self.notification.byUser.username];
    self.createdAtLabel.text = [self.notification.createdAt formattedAsTimeAgo];
    self.profileImageView.image = UserPlaceholderImage;
    [self updateNotificationTextAndImage];
    [self.notification.byUser getThumbnailProfileImageWithCompletionBlock:^(UIImage* image,User* user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.notification.byUser == user) {
                [self.profileImageView setImageWithAnimation:image];
            }
        });
    }];
}

- (void) updateNotificationTextAndImage
{
    NSString* text = nil;
    UIImage* image;
    if(self.notification.notificationType == NotificationTypeComment){
        text = @"commented on your sonic";
        image = [self notificationTypeImageComment];
    }
    else if(self.notification.notificationType == NotificationTypeFollow){
        text = @"is now following you";
        image = [self notificationTypeImageFollow];
    }
    else if(self.notification.notificationType == NotificationTypeLike){
        text = @"liked one of your sonics";
        image = [self notificationTypeImageLike];
    }
    else if(self.notification.notificationType == NotificationTypeResonic){
        text = @"resoniced one of your sonics";
        image = [self notificationTypeImageResonic];
    }
    self.notificationTextLabel.text = text;
    self.notificationTypeImageView.image = image;
}
- (UIImage*) notificationTypeImageLike
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"notificationlike.png"];
    }
    return image;
}
- (UIImage*) notificationTypeImageResonic
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"notificationresonic.png"];
    }
    return image;
}
- (UIImage*) notificationTypeImageComment
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"notificationcomment.png"];
    }
    return image;
}
- (UIImage*) notificationTypeImageFollow
{
    static UIImage* image = nil;
    if(image == nil){
        image =  [UIImage imageNamed:@"notificationfollow.png"];
    }
    return image;
}


@end
