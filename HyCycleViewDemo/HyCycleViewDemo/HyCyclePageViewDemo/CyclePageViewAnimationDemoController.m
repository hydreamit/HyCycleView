//
//  CyclePageViewAnimationDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewAnimationDemoController.h"

@implementation CyclePageViewAnimationDemoController

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        configure
        .headerViewUpAnimation(HyCyclePageViewHeaderViewUpAnimationCover)
        .headerViewDownAnimation(HyCyclePageViewHeaderViewDownAnimationScale);
    };
}

@end
