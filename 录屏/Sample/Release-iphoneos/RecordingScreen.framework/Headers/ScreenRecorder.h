//
//  ScreenRecorder.h
//  RecordingScreen
//
//  Created by 曹敬贺 on 15/4/28.
//  Copyright (c) 2015年 北京明兰网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
/***/
@protocol ScreenRecorderDelegate <NSObject>

- (void)ScreenRecordingFinished;

@end

@interface ScreenRecorder : NSObject
{
    __weak id<ScreenRecorderDelegate>_delegate;
}
//是否正在录制
@property (nonatomic,assign)BOOL isRecording;
//是否正在写入
@property (nonatomic,assign)BOOL isWriting;
//暂停
@property (nonatomic,assign)BOOL Pause;
//要录制的层
@property (nonatomic,weak)CALayer * captureLayer;
//帧率
@property (nonatomic,assign)NSInteger FPS;
//获取文件路径
@property (nonatomic,readonly)NSString * filePath;
//代理
@property (nonatomic,weak)id<ScreenRecorderDelegate> delegate;

-(void)StopRecording;
-(void)PauseRecording;
-(void)StartRecording;

@end
