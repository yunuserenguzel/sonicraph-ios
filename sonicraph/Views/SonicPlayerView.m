//
//  SonicPlayerView.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/13/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SonicPlayerView.h"
#import "SNCAPIManager.h"
#import <AVFoundation/AVFoundation.h>

#import "Configurations.h"

@interface SonicPlayerView ()

@property UIImageView* imageView;

@property AVAudioPlayer* audioPlayer;

@end

@implementation SonicPlayerView
{
    
}

- (CGRect) imageViewFrame
{
    CGRect frame = CGRectZero;
    frame.size = SonicSize;
    frame.origin = CGPointZero;
    return frame;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (id) init
{
    if (self = [super init]){
        [self setFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
        [self initViews];
        
    }
    return self;
}

- (void) initViews
{
    [self initializeImageView];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
}

- (void) tapped
{
    if([self.audioPlayer isPlaying]){
        [self.audioPlayer pause];
    }
    else{
        [self.audioPlayer play];
    }
}


- (void)setSonicUrl:(NSURL *)sonicUrl
{
    if([[self.sonicUrl path] isEqualToString:sonicUrl.path] != YES){
        _sonicUrl = sonicUrl;
        self.imageView.image = nil;
        [SNCAPIManager getSonic:sonicUrl withSonicBlock:^(SonicData *sonic, NSError *error) {
            if(self.sonicUrl == sonic.remoteSonicDataFileUrl){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.sonic = sonic;
                    //                self.imageView.image = sonic.image;
                });
            }
        }];
    }
}


- (void) initializeImageView
{

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.imageView];
}

- (void)setSonic:(SonicData *)sonic
{
    _sonic = sonic;
    self.imageView.image = self.sonic.image;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.sonic.sound error:nil];
}

- (void)setFrame:(CGRect)frame
{
    frame.size = SonicPlayerViewSize;
    [super setFrame:frame];
    
}


- (void)play
{
    [self.audioPlayer play];
}

- (void)stop
{
    [self.audioPlayer stop];
}

- (void)pause
{
    [self.audioPlayer pause];
}


@end
