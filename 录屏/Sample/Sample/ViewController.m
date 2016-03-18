//
//  ViewController.m
//  Sample
//
//  Created by 曹敬贺 on 15/4/28.
//  Copyright (c) 2015年 北京明兰网络科技有限公司. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<ScreenRecorderDelegate,AudioRecorderDelegate>
{
    ScreenRecorder * Srecorder;
    AudioRecorder * Arecorder;
    NSString * exportfilePath;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    //建议录制操作放在一个单例中去执行，然后当程序在录制过程中，无意间将程序退出到后台，通过AppDelegate的退出到后台的方法中，停止录制。这样就能保证录制不会因为终止而中断造成失败。这里我只简单举例用法，所以不用单例操作。
    
    UIButton * Start = [UIButton buttonWithType:UIButtonTypeCustom];
    Start.frame = CGRectMake(100, 100, 100, 30);
    [Start setTitle:@"开始录制" forState:UIControlStateNormal];
    [Start addTarget:self action:@selector(StartRecorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Start];
    
    UIButton * Stop = [UIButton buttonWithType:UIButtonTypeCustom];
    Stop.frame = CGRectMake(400, 100, 100, 30);
    [Stop setTitle:@"结束录制" forState:UIControlStateNormal];
    [Stop addTarget:self action:@selector(StopRecorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Stop];
    
    UIButton * Pause = [UIButton buttonWithType:UIButtonTypeCustom];
    Pause.frame = CGRectMake(700, 100, 100, 30);
    [Pause setTitle:@"暂停" forState:UIControlStateNormal];
    [Pause addTarget:self action:@selector(PauseRecorder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Pause];
    
    UIButton * Mix = [UIButton buttonWithType:UIButtonTypeCustom];
    Mix.frame = CGRectMake(400, 400, 100, 30);
    [Mix setTitle:@"混合" forState:UIControlStateNormal];
    [Mix addTarget:self action:@selector(MixClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Mix];
    
    Srecorder = [[ScreenRecorder alloc]init];
    Srecorder.delegate = self;
    Srecorder.captureLayer = self.view.layer;
    Srecorder.FPS = 30;
    
    Arecorder = [[AudioRecorder alloc]init];
    Arecorder.delegate = self;
    
    exportfilePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/output.mp4"];
    NSLog(@"%@",exportfilePath);
    
}

-(void)StartRecorder
{
    NSLog(@"开始录制");
    [Arecorder beginRecording];
    [Srecorder StartRecording];
}
-(void)PauseRecorder
{
    NSLog(@"暂停录制");//这里如果当前状态录制暂停，当再次点击暂停按钮，则为继续录制
    [Srecorder PauseRecording];
    [Arecorder pauseRecording];
}
-(void)StopRecorder
{
    NSLog(@"停止录制");
    [Arecorder endRecording];
    [Srecorder StopRecording];
}
-(void)ScreenRecordingFinished
{
    NSLog(@"录屏结束");
}
-(void)AudioFinished
{
    NSLog(@"录音结束");
}
-(void)MixClick
{
    NSLog(@"录制的视频路径:%@,录制的音频路径:%@",Srecorder.filePath,Arecorder.filePath);
    [MixVideoAndAudio mixVideo:Srecorder.filePath andAudio:Arecorder.filePath andCompleted:exportfilePath WithBlock:^(BOOL finish) {
        if (finish) {
            NSLog(@"合成完成");
        }else
        {
            NSLog(@"合成失败");
        }
    }];
}
-(void)dealloc
{
    
    Srecorder.delegate = nil;
    Srecorder = nil;
    Arecorder.delegate = nil;
    Arecorder = nil;
    exportfilePath = nil;
}

@end
