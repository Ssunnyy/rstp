//
//  MixVideoAndAudio.h
//  RecordingScreen
//
//  Created by 曹敬贺 on 15/4/28.
//  Copyright (c) 2015年 北京明兰网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MixVideoAndAudio : NSObject

+(void)mixVideo:(NSString *)videoPath andAudio:(NSString *)audioPath andCompleted:(NSString *)exportPath WithBlock:(void (^)(BOOL))block;

@end
