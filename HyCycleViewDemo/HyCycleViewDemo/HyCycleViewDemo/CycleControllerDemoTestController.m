//
//  CycleControllerDemoTestController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CycleControllerDemoTestController.h"


@implementation CycleControllerDemoTestController

- (void)configCycleView:(HyCycleViewProvider<HyCycleView *> *)provider index:(NSInteger)index {
    // 保持控制器引用
    provider.retainProvider = YES;
    __weak typeof(self) _self = self;
    NSArray<UIColor *> *colors = @[UIColor.purpleColor, UIColor.redColor, UIColor.greenColor, UIColor.blueColor];
    [provider view:^UIView * _Nonnull(HyCycleView * _Nonnull cycleView) {
        UIView *view = _self.view;
        view.backgroundColor = colors[index];
        return view;
    }];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
