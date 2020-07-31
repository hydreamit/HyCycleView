//
//  CyclePageViewTikTokHeaderView.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewTikTokHeaderView.h"
#import "UIView+HyFrame.h"


@interface CyclePageViewTikTokHeaderView()
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIView *bottomView;
@end


@implementation CyclePageViewTikTokHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.bottomView];
        self.imageView.frame = CGRectMake(0, 0, self.width, self.height / 3);
        self.bottomView.frame = CGRectMake(0, self.height / 3, self.width, self.height / 3 * 2);
    }
    return self;
}


- (void (^)(HyCyclePageView * _Nonnull, UIView * _Nonnull, NSInteger, CGFloat))hy_verticalScrollProgress {
    __weak typeof(self) _self = self;
    return ^(HyCyclePageView *cyclePageView, UIView *view, NSInteger index, CGFloat offset) {
        __strong typeof(_self) self = _self;
        if (offset <= 0) {
            if (offset >= -50) {
                self.imageView.frame = CGRectMake(0, offset + offset / 5, self.width, self.height / 3 - offset - offset / 5);
            } else {
                offset += 50;
                self.imageView.top = - 60 + offset;
                self.imageView.width = self.width - offset * 1.2;
                self.imageView.height = self.height / 3 + 60 - offset;
                self.imageView.centerXIsEqualTo(self.bottomView);
            }
        }
    };
}

- (UIImageView *)imageView {
    if (!_imageView) {
        
        _imageView = UIImageView.new;
        _imageView.image = [UIImage imageNamed:@"one"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = UIColor.orangeColor;
    }
    return _imageView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = UIView.new;
        UIColor *color = [UIColor colorWithRed:20.0 / 255 green:25.0/255 blue:35.0/255 alpha:1];
        _bottomView.backgroundColor = color;
        
        UIImageView *imageView = UIImageView.new;
        imageView.image = [UIImage imageNamed:@"two"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.size = CGSizeMake(100, 100);
        imageView.top = -30;
        imageView.left = 20;
        imageView.layer.cornerRadius = 50;
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderWidth = 5;
        
        imageView.layer.borderColor = color.CGColor;
        [_bottomView addSubview:imageView];
        _bottomView.clipsToBounds = NO;
        
    }
    return _bottomView;
}

@end
