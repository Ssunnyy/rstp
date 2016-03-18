//
//  AudioRecorder.h
//  RecordingScreen
//
//  Created by 曹敬贺 on 15/4/28.
//  Copyright (c) 2015年 北京明兰网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioRecorderDelegate <NSObject>

-(void)AudioFinished;

@end
@interface AudioRecorder : NSObject<AVAudioRecorderDelegate>
{
    __weak id<AudioRecorderDelegate>_delegate;
}

@property (nonatomic,weak)id<AudioRecorderDelegate>delegate;
@property (nonatomic,readonly)NSString * filePath;

-(void)beginRecording;
-(void)endRecording;
-(void)pauseRecording;

@end
