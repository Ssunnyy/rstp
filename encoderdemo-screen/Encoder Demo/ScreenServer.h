//
//  ScreenServer.h
//  Encoder Demo
//
//  Created by  MAC on 16/2/1.
//  Copyright © 2016年 Geraint Davies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ScreenServer : NSObject

@property(assign) NSUInteger frameRate; //帧速 默认是24

+ (ScreenServer*) server;
//开始录制
- (bool)startRecordingWithLayer:(CALayer*)layer;
//结束录制
- (void)stopRecording;

- (NSString*) getURL;

@end
