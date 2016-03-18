//
//  EncoderDemoViewController.m
//  Encoder Demo
//
//  Created by Geraint Davies on 11/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "EncoderDemoViewController.h"
#import "ScreenServer.h"

@implementation EncoderDemoViewController

@synthesize cameraView;
@synthesize serverAddress;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // this is not the most beautiful animation...
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startRecord:(id)sender {
    
    [[ScreenServer server] startRecordingWithLayer:self.view.layer];
    
    self.serverAddress.text = [[ScreenServer server] getURL];
}

- (IBAction)downRecord:(id)sender {
    
    [[ScreenServer server] stopRecording];
    
    self.serverAddress.text = @"已停止";
}
@end
