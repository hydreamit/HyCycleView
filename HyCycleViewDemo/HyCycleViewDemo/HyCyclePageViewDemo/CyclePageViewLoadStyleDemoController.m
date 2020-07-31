//
//  CyclePageViewLoadStyleDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewLoadStyleDemoController.h"

@implementation CyclePageViewLoadStyleDemoController

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        [configure loadStyle:HyCycleViewLoadStyleWillAppear];
    };
}

@end
