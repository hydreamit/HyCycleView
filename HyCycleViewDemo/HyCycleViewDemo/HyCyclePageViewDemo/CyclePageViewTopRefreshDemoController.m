//
//  CyclePageViewTopRefreshDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewTopRefreshDemoController.h"
#import <MJRefresh/MJRefresh.h>


@implementation CyclePageViewTopRefreshDemoController

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        
        configure
        .headerRefreshStyle(HyCyclePageViewHeaderRefreshStyleTop)
        .headerRefresh(^(HyCyclePageView *pageView, UIScrollView *scrollView, NSInteger index){
            
            __block typeof(scrollView) weakScrollView = scrollView;
            scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                         (int64_t)(.5 * NSEC_PER_SEC)),
                                           dispatch_get_main_queue(), ^{
                                               [weakScrollView.mj_header endRefreshing];
                                           });
            }];
            
            if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                scrollView.mj_header.ignoredScrollViewContentInsetTop = 290;
            }
        })
        .footerRefresh(^(HyCyclePageView *pageView, UIScrollView *scrollView, NSInteger index){
            
            __block typeof(scrollView) weakScrollView = scrollView;
            scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(.5 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [weakScrollView.mj_footer endRefreshing];
                               });
            }];
        });
    };
}

@end
