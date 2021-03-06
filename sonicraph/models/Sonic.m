//
//  Sonic.m
//  ;
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Sonic.h"
#import "SonicData.h"
#import "TypeDefs.h"
#import "AuthenticationManager.h"

@implementation Sonic

- (id)init
{
    if(self = [super init]){
        [self registerForNotification];
    }
    return self;
}

- (void)updateWithSonic:(Sonic *)sonic
{
    if([[self sonicId] isEqualToString:sonic.sonicId] && self != sonic){
        self.resonicCount = sonic.resonicCount;
        self.likeCount = sonic.likeCount;
        self.commentCount = sonic.commentCount;
        self.isLikedByMe = sonic.isLikedByMe;
        self.isResonicedByMe = sonic.isResonicedByMe;
        self.isCommentedByMe = sonic.isCommentedByMe;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:NotificationUpdateViewForSonic
         object:self];
    }
}

- (void) registerForNotification
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateWithNotification:)
     name:NotificationUpdateSonic
     object:nil];
}

- (void) updateWithNotification:(NSNotification*)notification
{
    if ([notification.object isKindOfClass:[Sonic class]]) {
        [self updateWithSonic:notification.object];
    }
}

- (SonicData *)sonicData
{
    if(_sonicData == nil){
        self.sonicData = [SonicData sonicDataWithSonic:self];
    }
    return _sonicData;
}

- (void)setSonic:(SonicData *)sonicData
{
    _sonicData = sonicData;
    sonicData.sonic = self;
}

- (UIImage *)getImage
{
    return [[self sonicData] image];
}

- (NSData *)getSound
{
    return [[self sonicData] sound];
}

- (BOOL)isMySonic
{
    return [[[[AuthenticationManager sharedInstance] authenticatedUser] userId] isEqualToString:self.owner.userId];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
