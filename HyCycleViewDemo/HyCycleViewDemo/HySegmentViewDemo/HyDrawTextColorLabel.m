//
//  HyDrawTextColorLabel.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/25.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HyDrawTextColorLabel.h"


@interface HyDrawTextColorLabel ()
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *drawTextColor;
@end


@implementation HyDrawTextColorLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self.drawTextColor set];
    
    CGFloat width = ABS(self.progress) * rect.size.width;
    if (self.progress < 0) {
        rect.origin.x = rect.size.width - width;
    }
    rect.size.width = width;
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

- (void)drawTextColor:(UIColor *)color
             progress:(CGFloat)progress {
    
    self.drawTextColor = color;
    self.progress = progress;
    [self setNeedsDisplay];
}

@end
