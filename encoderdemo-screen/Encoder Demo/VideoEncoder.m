//
//  VideoEncoder.m
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "VideoEncoder.h"

@implementation VideoEncoder

@synthesize path = _path;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(int) height andWidth:(int) width
{
    VideoEncoder* enc = [VideoEncoder alloc];
    [enc initPath:path Height:height andWidth:width];
    return enc;
}


- (void) initPath:(NSString*)path Height:(int) height andWidth:(int) width
{
    self.path = path;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url = [NSURL fileURLWithPath:self.path];
    
    NSError  *error = nil;
    videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);

    //Configure videoWriterInput
    NSMutableDictionary * videoCompressionProps = [NSMutableDictionary dictionary];
    [videoCompressionProps setObject: [NSNumber numberWithInt:width*height] forKey: AVVideoAverageBitRateKey];
    //[videoCompressionProps setObject: [NSNumber numberWithInt:30] forKey: AVVideoMaxKeyFrameIntervalKey];
    //[videoCompressionProps setObject: AVVideoProfileLevelH264Main41 forKey: AVVideoProfileLevelKey];
    
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:height], AVVideoHeightKey,
                                   videoCompressionProps, AVVideoCompressionPropertiesKey,
                                   nil];
    
    videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(videoWriterInput);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    
    //add input
    [videoWriter addInput:videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
}

- (void) finishWithCompletionHandler:(void (^)(void))handler
{
    [videoWriter finishWritingWithCompletionHandler: handler];
}

- (BOOL) encodeFrame:(CGImageRef)cgImage andTime:(CMTime)time;
{

    if (videoWriter.status == AVAssetWriterStatusFailed)
    {
        NSLog(@"writer error %@", videoWriter.error.localizedDescription);
        return NO;
    }
    //write
    if (![videoWriterInput isReadyForMoreMediaData])
    {
        NSLog(@"Not ready for video data");
        return NO;
    }
    CVPixelBufferRef pixelBuffer = NULL;
    CFDataRef image = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    
    int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, avAdaptor.pixelBufferPool, &pixelBuffer);
    if(status != 0)
    {
        //could not get a buffer from the pool
        NSLog(@"Error creating pixel buffer:  status=%d", status);
    }
    // set image data into pixel buffer
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    uint8_t* destPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
    //XXX:  will work if the pixel buffer is contiguous and has the same bytesPerRow as the input data
    CFDataGetBytes(image, CFRangeMake(0, CFDataGetLength(image)), destPixels);
    
    if(status == 0)
    {
        BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
        if (!success)
            return NO;
    }
    
    //clean up
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    CVPixelBufferRelease( pixelBuffer );
    CFRelease(image);
    
    return YES;
}

@end
