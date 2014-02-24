//
//  SNCHomeTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/14/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCHomeTableCell.h"
#import "SonicData.h"
#import "SonicPlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import "SNCAPIManager.h"

#import "TypeDefs.h"
#import "Configurations.h"
#import "NSDate+NVTimeAgo.h"
#import "AuthenticationManager.h"

#define DeleteConfirmAlertViewTag 10001
#define ResonicConfirmAlertViewTag 20020

#define SonicActionSheetTag 121212
#define DeleteResonicActionSheetTag 123123

#define ButtonsTop 384.0
#define LabelsTop 384.0


@interface SNCHomeTableCell () <UIActionSheetDelegate,UIAlertViewDelegate>

@property SonicPlayerView* sonicPlayerView;
@property UIImageView* cellSpacingView;

@end

@implementation SNCHomeTableCell

- (CGRect) userImageViewFrame
{
    return  CGRectMake(7.0, 7.0, 50.0, 50.0);
}
- (CGRect) userImageMaskViewFrame
{
    return [self userImageViewFrame];
}
- (CGRect) fullnameLabelFrame
{
    return CGRectMake(64.0, 7.0, 200.0, 20.0);
}
- (CGRect) usernameLabelFrame
{
    return CGRectMake(64.0, 25.0, 244.0, 18.0);
}
- (CGRect) timestampLabelFrame
{
    return CGRectMake(200.0, 7.0, 110.0, 20.0);
}
- (CGRect) resonicedByUsernameLabelFrame
{
    return CGRectMake(78, 43.0, 200.0, 16.0);
}
- (CGRect) resonicImageFrame
{
    return CGRectMake(64.0, 43.0, 12.0  , 16.0);
}
- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 64.0, 320.0, 320.0);
}
- (CGRect) likeButtonFrame
{
    return CGRectMake(0.0, ButtonsTop, 44.0, 44.0);
}
- (CGRect) likesLabelFrame
{
    return CGRectMake(44.0, LabelsTop, 44.0, 44.0);
}
- (CGRect) commentButtonFrame
{
    return CGRectMake(88.0, ButtonsTop, 44.0, 44.0);
}
- (CGRect) commentsLabelFrame
{
    return CGRectMake(132.0, LabelsTop, 44.0, 44.0);
}
- (CGRect) resonicButtonFrame
{
    return CGRectMake(176.0, ButtonsTop, 44.0, 44.0);
}
- (CGRect) resonicsLabelFrame
{
    return CGRectMake(220.0, LabelsTop, 44.0, 44.0);
}
- (CGRect) moreButtonFrame
{
    return CGRectMake(264.0, ButtonsTop, 44.0, 44.0);
}
- (CGRect) cellSpacingViewFrame
{
    return CGRectMake(0.0, HeightForHomeCell - 22.0, 320.0, 22.0);
}

- (Sonic*) actualSonic
{
    return self.sonic.isResonic ? self.sonic.originalSonic : self.sonic;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initViews];
        
    }
    return self;
}

- (void) initViews
{
    
    self.sonicPlayerView = [[SonicPlayerView alloc] initWithFrame:[self sonicPlayerViewFrame]];
    [self addSubview:self.sonicPlayerView];
    [self addSubview:self.usernameLabel];
    [self initUserInfo];
    [self initLabels];
    [self initButtons];
    
    self.cellSpacingView = [[UIImageView alloc] initWithFrame:[self cellSpacingViewFrame]];
    [self.cellSpacingView setBackgroundColor:CellSpacingGrayColor];
    [self addSubview:self.cellSpacingView];
    
    UIView* lineViewTop = [[UIView alloc] initWithFrame:CGRectMake(0.0, [self cellSpacingViewFrame].size.height-1.0, 320.0, 1.0)];
    [lineViewTop setBackgroundColor:CellSpacingLineGrayColor];
    [self.cellSpacingView addSubview:lineViewTop];
    
    UIView* lineViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 1.0)];
    [lineViewBottom setBackgroundColor:CellSpacingLineGrayColor];
    [self.cellSpacingView addSubview:lineViewBottom];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshSonicNotification:)
     name:NotificationUpdateViewForSonic
     object:nil];
}

- (void) initUserInfo
{
    self.userImageView = [[UIImageView alloc] initWithFrame:[self userImageViewFrame]];
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.userImageView setImage:SonicPlaceholderImage];
    [self.userImageView setClipsToBounds:YES];
    [self.userImageView.layer setCornerRadius:8.0];
    [self addSubview:self.userImageView];
    
    self.userImageMaskView = [[UIImageView alloc] initWithFrame:[self userImageMaskViewFrame]];
    [self addSubview:self.userImageMaskView];

    self.fullnameLabel = [[UILabel alloc] initWithFrame:[self fullnameLabelFrame]];
    [self.fullnameLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
//    self.fullnameLabel.textColor = NavigationBarBlueColor;
//    self.fullnameLabel.textColor = rgb(00.0, 00.0, 0.0);
    self.fullnameLabel.textColor = FullnameTextColor;
    [self addSubview:self.fullnameLabel];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [self.usernameLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:self.usernameLabel];

    self.timestampLabel = [[UILabel alloc] initWithFrame:[self timestampLabelFrame]];
    [self.timestampLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
    [self.timestampLabel setTextColor:[UIColor lightGrayColor]];
    [self.timestampLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:self.timestampLabel];
    
    self.resonicedByUsernameLabel = [[UILabel alloc] initWithFrame:[self resonicedByUsernameLabelFrame]];
    [self.resonicedByUsernameLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.resonicedByUsernameLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:self.resonicedByUsernameLabel];
    
    self.resonicImageView = [[UIImageView alloc] initWithFrame:[self resonicImageFrame]];
    self.resonicImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resonicImageView.clipsToBounds = YES;
    [self.resonicImageView setImage:[UIImage imageNamed:@"ResonicGrey.png"]];
    [self addSubview:self.resonicImageView];
    
    [self.usernameLabel setUserInteractionEnabled:YES];
    [self.userImageView setUserInteractionEnabled:YES];
    
    UIGestureRecognizer* tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.usernameLabel addGestureRecognizer:tapGesture];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.userImageView addGestureRecognizer:tapGesture];
}

- (void) tapGesture
{
    [self.delegate openProfileForUser:[self actualSonic].owner];
}

- (void) refreshSonicNotification:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if(sonic == self.sonic || sonic == self.sonic.originalSonic){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureViews];
        });
    }
}

- (void) initLabels
{   UITapGestureRecognizer* tapGesture;
    self.likesCountLabel = [[UILabel alloc] initWithFrame:[self likesLabelFrame]];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLikes)];
    [self.likesCountLabel addGestureRecognizer:tapGesture];

    self.commentsCountLabel = [[UILabel alloc] initWithFrame:[self commentsLabelFrame]];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openComments)];
    [self.commentsCountLabel addGestureRecognizer:tapGesture];
    
    self.resonicsCountLabel = [[UILabel alloc] initWithFrame:[self resonicsLabelFrame]];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openResonics)];
    [self.resonicsCountLabel addGestureRecognizer:tapGesture];
    
    for(UILabel* label in @[self.likesCountLabel,self.commentsCountLabel, self.resonicsCountLabel])
    {
        [label setFont:[UIFont boldSystemFontOfSize:16.0]];
        [label setTextColor:[UIColor grayColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:label];
        [label setUserInteractionEnabled:YES];
    }
    
}

- (void) initButtons
{
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setFrame:[self likeButtonFrame]];
    [self.likeButton setImage:[UIImage imageNamed:@"LikeGrey.png"] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"LikePink.png"] forState:UIControlStateSelected];
    [self.likeButton addTarget:self action:@selector(likeSonic) forControlEvents:UIControlEventTouchUpInside];

    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentButton setFrame:[self commentButtonFrame]];
    [self.commentButton setImage:[UIImage imageNamed:@"CommentGrey.png"] forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(commentSonic) forControlEvents:UIControlEventTouchUpInside];
    
    self.resonicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resonicButton setFrame:[self resonicButtonFrame]];
    [self.resonicButton setImage:[UIImage imageNamed:@"ResonicGrey.png"] forState:UIControlStateNormal];
    [self.resonicButton setImage:[UIImage imageNamed:@"ResonicPink.png"] forState:UIControlStateSelected];
    [self.resonicButton addTarget:self action:@selector(resonic) forControlEvents:UIControlEventTouchUpInside];

    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreButton setFrame:[self moreButtonFrame]];
    [self.moreButton setImage:[UIImage imageNamed:@"MoreGrey.png"] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    [@[self.likeButton,self.commentButton,self.resonicButton,self.moreButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setTintColor:PinkColor];
        [button addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
        [self addSubview:button];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([object isKindOfClass:[UIButton class]]){
        UIButton* button = object;
        if([button state] == UIControlStateHighlighted){
            [button setTintColor:[PinkColor colorWithAlphaComponent:0.5]];
        } else {
            [button setTintColor:PinkColor];
        }
    }
}

- (void) share
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Share on Facebook",@"Share on Twitter",@"Copy URL",@"Open Details", nil];
    actionSheet.tag = SonicActionSheetTag;
    [actionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == SonicActionSheetTag){
        if(buttonIndex == 0){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Do you confirm to delete this sonic?" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
            alert.tag = DeleteConfirmAlertViewTag;
            [alert show];
        }
    } else if(actionSheet.tag == DeleteResonicActionSheetTag){
        if(buttonIndex == 0) {
            if(self.sonic.isResonic){
                [SNCAPIManager deleteSonic:self.sonic withCompletionBlock:^(BOOL successful) {
                    [SNCAPIManager deleteResonic:self.sonic.originalSonic withCompletionBlock:^(Sonic *sonic) {
                        [self.sonic.originalSonic updateWithSonic:sonic];
                    } andErrorBlock:nil];
                } andErrorBlock:^(NSError *error) {
                    
                }];
            } else {
                [SNCAPIManager deleteResonic:self.sonic withCompletionBlock:^(Sonic *sonic) {
                    [self.sonic updateWithSonic:sonic];
                } andErrorBlock:nil];
            }
        }
    }
    
}

- (void) resonic
{
    if([self.resonicButton isSelected]){
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Delete resonic"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Delete"
                                      otherButtonTitles: nil];
        actionSheet.tag = DeleteResonicActionSheetTag;
        [actionSheet showInView:self];
        
    } else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"Resonic"
                              message:@"Do you want to resonic this?"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Resonic!", nil];
        alert.tag = ResonicConfirmAlertViewTag;
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == DeleteConfirmAlertViewTag){
        if(buttonIndex == 0){
            [SNCAPIManager deleteSonic:self.sonic withCompletionBlock:nil andErrorBlock:nil];
        }
    }
    else if(alertView.tag == ResonicConfirmAlertViewTag){
        if(buttonIndex == 1){
            Sonic* sonicToBeResoniced = [self actualSonic];
            [SNCAPIManager resonicSonic:sonicToBeResoniced withCompletionBlock:^(Sonic *sonic) {
                [sonicToBeResoniced updateWithSonic:sonic];
            } andErrorBlock:nil];
        }
    }
}


- (void) openLikes
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeOpenLikes];
}

- (void) openComments
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeOpenComments];
}

- (void) openResonics
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeOpenResonics];
}

- (void) commentSonic
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeComment];
}

- (void)likeSonic
{
    Sonic* currentSonic = [self actualSonic];
    [self.likeButton setHighlighted:YES];
    if ([self.likeButton isSelected]){
        [self.likeButton setSelected:NO];
        [SNCAPIManager dislikeSonic:currentSonic withCompletionBlock:^(Sonic *sonic) {
            [currentSonic updateWithSonic:sonic];
        } andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:YES];
        }];
    }
    else {
        [self.likeButton setSelected:YES];
        [SNCAPIManager likeSonic:currentSonic withCompletionBlock:^(Sonic *sonic) {
            [currentSonic updateWithSonic:sonic];
        } andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:YES];
        }];
    }
}

- (void)setSonic:(Sonic *)sonic
{
    if(_sonic != sonic){
        _sonic = sonic;
        [self configureViews];
    }
}

- (void) configureViews
{
    if(self.sonic.isResonic){
        [self configureViewsForSonic:self.sonic.originalSonic];
        [self.resonicedByUsernameLabel setText:[NSString stringWithFormat:@"resoniced by %@",self.sonic.owner.username]];
        [self.resonicImageView setHidden:NO];
    } else {
        [self configureViewsForSonic:self.sonic];
        [self.resonicedByUsernameLabel setText:[NSString stringWithFormat:@""]];
        [self.resonicImageView setHidden:YES];
    }
}

- (void) configureViewsForSonic:(Sonic*)sonic
{
    [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:sonic.sonicUrl]];
    [self.fullnameLabel setText:[sonic.owner fullName]];
    [self.usernameLabel setText:[NSString stringWithFormat:@"@%@",[sonic.owner username]]];
    [self.userImageView setImage:SonicPlaceholderImage];
    [sonic.owner getThumbnailProfileImageWithCompletionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userImageView setImage:object];
        });
    }];
    [self.timestampLabel setText:[[sonic creationDate] formattedAsTimeAgo]];
    if([sonic.owner.userId isEqualToString:[[[AuthenticationManager sharedInstance] authenticatedUser] userId]]){
        [self.resonicButton setEnabled:NO];
    } else {
        [self.resonicButton setEnabled:YES];
        [self.resonicButton setSelected:sonic.isResonicedByMe];
    }
    [self.likeButton setSelected:sonic.isLikedByMe];
    self.likesCountLabel.text = [NSString stringWithFormat:@"%d",sonic.likeCount];
    self.commentsCountLabel.text = [NSString stringWithFormat:@"%d",sonic.commentCount];
    self.resonicsCountLabel.text = [NSString stringWithFormat:@"%d",sonic.resonicCount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellWonCenterOfTableView
{
    [self.sonicPlayerView play];
}

- (void) cellLostCenterOfTableView
{
    [self.sonicPlayerView pause];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
//- (void)prepareForReuse
//{
//    self.sonic = nil;
//    [self.usernameLabel setText:@""];
//    [self.userImageView setImage:SonicPlaceholderImage];
//}


@end
