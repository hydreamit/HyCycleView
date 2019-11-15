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
@property (nonatomic, assign) CGRect drawRect;
@property (nonatomic, strong) UIColor *drawTextColor;
@property (nonatomic, assign) BOOL isDrewRect;
@end


@implementation HyDrawTextColorLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self.drawTextColor set];
    
    if (self.isDrewRect) {
        UIRectFillUsingBlendMode(self.drawRect, kCGBlendModeSourceIn);
    } else {
        CGFloat width = ABS(self.progress) * rect.size.width;
        if (self.progress < 0) {
            rect.origin.x = rect.size.width - width;
        }
        rect.size.width = width;
        UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
    }
}

- (void)drawTextColor:(UIColor *)color
             progress:(CGFloat)progress {
    
    self.isDrewRect = NO;
    self.drawTextColor = color;
    self.progress = progress;
    [self setNeedsDisplay];
}

- (void)drawTextColor:(UIColor *)color
                 rect:(CGRect)rect {
    
    self.isDrewRect = YES;
    self.drawTextColor = color;
    self.drawRect = rect;
    [self setNeedsDisplay];
}

@end
