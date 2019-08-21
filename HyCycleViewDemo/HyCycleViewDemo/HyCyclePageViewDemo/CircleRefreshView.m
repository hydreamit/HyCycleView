//
//  CircleRefreshView.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CircleRefreshView.h"

@interface IDCMCircleProgressLayer : CALayer
@property (nonatomic, assign) CGFloat progress;
@end
@implementation IDCMCircleProgressLayer
- (void)drawInContext:(CGContextRef)ctx {
    CGFloat radius = self.bounds.size.width / 2;
    CGFloat lineWidth = 1.5;
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius - lineWidth / 2 startAngle:0.f endAngle:M_PI * 2 * self.progress clockwise:YES];
    CGContextSetRGBStrokeColor(ctx, 1.0, 0, 0, 1.0);
    CGContextSetLineWidth(ctx, 1.5);
    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);
}
- (instancetype)initWithLayer:(IDCMCircleProgressLayer *)layer {
    if (self = [super initWithLayer:layer]) {
        self.progress = layer.progress;
    }
    return self;
}
+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}
@end

@interface CircleRefreshView()
@property (nonatomic, strong) IDCMCircleProgressLayer *circleProgressLayer;
@property (nonatomic, assign) BOOL animationing;
@property (nonatomic, assign, getter=isStartAnima) BOOL startAnima;
@property (nonatomic, assign) CGFloat currentAngle;
@end

@implementation CircleRefreshView
- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.currentAngle = .0;
        self.circleProgressLayer = [IDCMCircleProgressLayer layer];
        self.circleProgressLayer.frame = self.bounds;
        self.circleProgressLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:self.circleProgressLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    self.circleProgressLayer.hidden = NO;
    if (self.animationing) {return;}
    
    if (progress > 0.9) {
        [self progressAnimationWithProgress:.9];
        [self rotationAnimationWithAngle:(progress - .9) / 2];
    } else {
        [self progressAnimationWithProgress:progress];
    }
}

- (void)startAnimation {
    [self circleProgress:.9];
    [self rotationAnimation];
}

- (void)progressAnimationWithProgress:(CGFloat)progress {
    
    _progress = progress;
    self.circleProgressLayer.hidden = NO;
    [self circleProgress:progress];
}

- (void)circleProgress:(CGFloat)progress {
    
    [self.circleProgressLayer removeAnimationForKey:@"rotationAni"];
    CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"progress"];
    ani.toValue = @(progress);
    ani.removedOnCompletion = YES;
    ani.fillMode = kCAFillModeForwards;
    [self.circleProgressLayer addAnimation:ani forKey:@"progressAni"];
    self.circleProgressLayer.progress = progress;
    [self.circleProgressLayer setNeedsDisplay];
}

- (void)rotationAnimation {
    
    self.circleProgressLayer.hidden = NO;
    self.animationing = YES;
    [self.circleProgressLayer removeAnimationForKey:@"progressAni"];
    if ([self.circleProgressLayer animationForKey:@"rotationAni"] == nil) {
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue         = @(self.currentAngle);
        rotationAnimation.toValue           = @((M_PI * 100000) + self.currentAngle);
        rotationAnimation.duration          = .3 * 100000;
        rotationAnimation.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        rotationAnimation.removedOnCompletion = NO;
        [self.circleProgressLayer addAnimation:rotationAnimation forKey:@"rotationAni"];
    }
}

- (void)rotationAnimationWithAngle:(CGFloat)angle {
    if (angle > M_PI) {
        angle = M_PI;
    }
    [self.circleProgressLayer setValue:@(angle) forKeyPath:@"transform.rotation.z"];
    self.currentAngle = angle;
}

- (void)stopAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(.25 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       self.startAnima = NO;
                       self.animationing = NO;
                       self.progress = 0.0;
                       self.currentAngle = 0.0;
                       self.circleProgressLayer.hidden = YES;
                       self.circleProgressLayer.transform = CATransform3DIdentity;
                       [self.circleProgressLayer removeAnimationForKey:@"progressAni"];
                       [self.circleProgressLayer removeAnimationForKey:@"rotationAni"];
                   });
}

@end
