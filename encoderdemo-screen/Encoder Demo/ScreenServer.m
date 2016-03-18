//
//  ScreenServer.m
//  Encoder Demo
//
//  Created by  MAC on 16/2/1.
//  Copyright © 2016年 Geraint Davies. All rights reserved.
//

#import "ScreenServer.h"
#import "AVEncoder.h"
#import "RTSPServer.h"


static ScreenServer* theServer;

@interface ScreenServer  () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    
    AVEncoder* _encoder;
    
    RTSPServer* _rtsp;
    
    //
    //recording state
    BOOL           _recording;     //正在录制中
    BOOL           _writing;       //正在将帧写入文件
    NSDate         *startedAt;     //录制的开始时间
    CGContextRef   context;        //绘制layer的context
    NSTimer        *timer;         //按帧率写屏的定时器
    
    //id<THCaptureDelegate> _delegate;     //代理
}

@property(nonatomic) CALayer *captureLayer;//要绘制的目标layer

@end


@implementation ScreenServer

+ (void) initialize
{
    // test recommended to avoid duplicate init via subclass
    if (self == [ScreenServer class])
    {
        theServer = [[ScreenServer alloc] init];
    }
}

+ (ScreenServer*) server
{
    return theServer;
}

-(instancetype)init
{
    if (self = [super init]) {
        
        _frameRate = 24;
    }
    return self;
}

- (bool)startRecordingWithLayer:(CALayer *)layer
{
    bool result = NO;
    if (! _recording && layer)
    {
        _captureLayer = layer;
        result = [self setUpWriter];
        if (result)
        {
            startedAt = [NSDate date];
            _recording = true;
            _writing = false;
            
            //绘屏的定时器
            NSDate *nowDate = [NSDate date];
            timer = [[NSTimer alloc] initWithFireDate:nowDate interval:1.0/_frameRate target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
    }
    return result;
}

- (void)stopRecording
{
    if (_recording) {
        _recording = false;
        [timer invalidate];
        timer = nil;
        [self completeRecordingSession];
        [self cleanupWriter];
        
        if (_rtsp)
        {
            [_rtsp shutdownServer];
        }
    }
}

- (void)drawFrame
{
    if (!_writing) {
        
        _writing = true;
        
        size_t width  = CGBitmapContextGetWidth(context);
        size_t height = CGBitmapContextGetHeight(context);
        
        CGContextClearRect(context, CGRectMake(0, 0,width , height));
        [self.captureLayer renderInContext:context];
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        
        if (_recording) {
            float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0;
            CMTime time = CMTimeMake((int)millisElapsed, 1000);
            
            [_encoder encodeFrame:cgImage andTime:time];
        }
        
        CGImageRelease(cgImage);
        
        _writing = false;
    }
}

static NSString* const kFileName=@"output.mp4";

- (NSString*)tempFilePath {
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kFileName];
    
    return filePath;
}

-(BOOL) setUpWriter {
    
    CGSize size=self.captureLayer.frame.size;
    float scale = [UIScreen mainScreen].scale;
    scale = 1;
    //retina
    size.width = size.width * scale;
    size.height = size.height * scale;
    
    //Clear Old TempFile
    NSError  *error = nil;
    NSString *filePath=[self tempFilePath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        if ([fileManager removeItemAtPath:filePath error:&error] == NO)
        {
            NSLog(@"Could not delete old recording file at path:  %@", filePath);
            return NO;
        }
    }
    
    // create an encoder
    _encoder = [AVEncoder encoderForHeight:size.height andWidth:size.width];
    [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
        if (_rtsp != nil)
        {
            _rtsp.bitrate = _encoder.bitspersecond;
            [_rtsp onVideoData:data time:pts];
        }
        return 0;
    } onParams:^int(NSData *data) {
        _rtsp = [RTSPServer setupListener:data];
        return 0;
    }];
    
    
    //create context
    if (context== NULL)
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        context = CGBitmapContextCreate (NULL,
                                         size.width,
                                         size.height,
                                         8,//bits per component
                                         size.width * 4,
                                         colorSpace,
                                         kCGImageAlphaNoneSkipFirst);
        CGColorSpaceRelease(colorSpace);
        CGContextSetAllowsAntialiasing(context,NO);
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
        CGContextConcatCTM(context, flipVertical);
        //////////reatin
        CGContextScaleCTM(context, scale, scale);
        
    }
    if (context== NULL)
    {
        fprintf (stderr, "Context not created!");
        return NO;
    }
    
    return YES;
}

- (void) cleanupWriter {
    
    startedAt = nil;
    
    CGContextRelease(context);
    context=NULL;
}

- (void) completeRecordingSession {
    
    [_encoder shutdown];
}


- (NSString*) getURL
{
    NSString* ipaddr = [RTSPServer getIPAddress];
    NSString* url = [NSString stringWithFormat:@"rtsp://%@/", ipaddr];
    return url;
}


@end
