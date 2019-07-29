//
//  CyclePageViewHoverOffsetDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewHoverOffsetDemoController.h"


@interface CyclePageViewHoverOffsetDemoController ()
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) CGFloat lastAlpha;
@end


@implementation CyclePageViewHoverOffsetDemoController
@dynamic scrollView;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.navigationController.navigationBar setAlpha:self.lastAlpha];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setAlpha:1.f];
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    
    CGFloat naviHeight = 64;
    if ([[UIApplication sharedApplication].keyWindow respondsToSelector:NSSelectorFromString(@"safeAreaInsets")]) {
        naviHeight = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44;
    }
    
    CGFloat hoverViewH = 40;
    CGFloat headerViewH = 250;
    
    __weak typeof(self) weakSelf = self;
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        
        configure
        .hoverOffset(naviHeight)
        .headerViewUpAnimation(HyCyclePageViewHeaderViewUpAnimationCover)
        .headerViewDownAnimation(HyCyclePageViewHeaderViewDownAnimationScale)
        .verticalScroll(^(HyCyclePageView * cyclePageView,
                          CGFloat offsetY,
                          NSInteger currentPage) {
                        
            CGFloat margin = headerViewH - (naviHeight + hoverViewH);
            if (offsetY >= margin) {
                [weakSelf.navigationController.navigationBar setAlpha:1.0f];
            }else if (offsetY < 0) {
                [weakSelf.navigationController.navigationBar setAlpha:.0f];
            }else {
                [weakSelf.navigationController.navigationBar setAlpha:(offsetY / margin)];
            }
            weakSelf.lastAlpha = weakSelf.navigationController.navigationBar.alpha;
        });
    };
}

@end
