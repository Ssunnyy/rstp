//
//  HXMovieButton.m
//  Encoder Demo
//
//  Created by  MAC on 16/2/1.
//  Copyright © 2016年 Geraint Davies. All rights reserved.
//

#import "HXMovieButton.h"

@implementation HXMovieButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    // Retrieve the touch point
    beginPoint = [[touches anyObject] locationInView:self]; //记录第一个点，以便计算移动距离
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    // Move relative to the original touch point
    // 计算移动距离，并更新图像的frame
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGRect frame = [self frame];
    frame.origin.x += pt.x - beginPoint.x;
    frame.origin.y += pt.y - beginPoint.y;
    [self setFrame:frame];
    
}

@end
