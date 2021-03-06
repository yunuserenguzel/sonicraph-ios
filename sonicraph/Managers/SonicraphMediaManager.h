//
//  SonicMediaManager.h
//  AvCamTest
//
//  Created by Yunus Eren Guzel on 9/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Mp3ConverterInterface.h"

typedef void (^ ImageBlock)(UIImage* image);

@class SonicraphMediaManager;

@protocol SonicraphMediaProtocol <NSObject>

- (void) manager:(SonicraphMediaManager*)manager audioDataReady:(NSData*)data;

- (void) audioRecordStartedForManager:(SonicraphMediaManager*)manager ;

- (void) microphonePermissionDeniedForManager:(SonicraphMediaManager*)manager;

- (void) sonicraphMediaManagerReady:(SonicraphMediaManager*)manager;

@end

@interface SonicraphMediaManager : NSObject <AVAudioRecorderDelegate>

@property (nonatomic) UIView* cameraView;

@property (weak) id<SonicraphMediaProtocol> delegate;

@property (readonly) AVAudioRecorder *audioRecorder;

- (id) initWithView:(UIView*)view;

- (void) prepareForCapture;

- (void) takePictureWithCompletionBlock:(ImageBlock)completionBlock;

- (void) startAuidoRecording;

- (void) stopAudioRecording;

- (void) startCamera;

- (void) stopCamera;

- (void) useFrontCamera;

- (void) useMainCamera;

- (void) focusCameraToPoint:(CGPoint)point withCompletionBlock:(void(^)())completionBlock;

- (BOOL) setFlashMode:(AVCaptureFlashMode)flashMode;

@end
