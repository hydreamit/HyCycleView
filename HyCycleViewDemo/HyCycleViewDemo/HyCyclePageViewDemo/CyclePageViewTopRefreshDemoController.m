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
#import "CircleRefreshView.h"
#define HeaderRefreshTop 50


@interface CyclePageViewTopRefreshDemoController ()
@property (nonatomic,strong) HyCyclePageView *cyclePageView;
@property (nonatomic,strong) CircleRefreshView *headerRefreshView;
@end


@implementation CyclePageViewTopRefreshDemoController
@dynamic cyclePageView;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
        [self beginRefreshIsAuto:YES];
    }
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    __weak typeof(self) weakSelf = self;
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        
        configure
        .headerRefreshStyle(HyCyclePageViewHeaderRefreshStyleTop)
        .headerRefresh(^(HyCyclePageView *pageView, UIScrollView *scrollView, NSInteger index){
            
            if (weakSelf.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                
                // 简单自定义一个
                
//                __block typeof(scrollView) weakScrollView = scrollView;
//                scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
//                                                 (int64_t)(3 * NSEC_PER_SEC)),
//                                   dispatch_get_main_queue(), ^{
//                                       [weakScrollView.mj_header endRefreshing];
//                                   });
//                }];
//                 scrollView.mj_header.ignoredScrollViewContentInsetTop = 290;
                
            } else {
                
                __block typeof(scrollView) weakScrollView = scrollView;
                scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                 (int64_t)(3 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       [weakScrollView.mj_header endRefreshing];
                                   });
                }];
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
        })
        .verticalScroll(^(HyCyclePageView *cyclePageView,
                           CGFloat offsetY,
                           NSInteger currentPage) {
            if (weakSelf.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                if (offsetY < - 20 && !weakSelf.headerRefreshView.animationing) {
                    weakSelf.headerRefreshView.progress = - (offsetY + 20) / (HeaderRefreshTop - 20);
                }
            }
        });;
    };
}

- (UIView *)headerView {
    
    UIView *superHeaderView = [super headerView];
    if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
        self.headerRefreshView =
        [[CircleRefreshView alloc] initWithFrame:CGRectMake((superHeaderView.width - 30) / 2, - 40, 30, 30)];
        [superHeaderView addSubview:self.headerRefreshView];
    }
    return superHeaderView;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    if (!self.headerRefreshView.animationing) {
        CGFloat height = HeaderRefreshTop + 250 + 40;
        if (scrollView.contentOffset.y < - height) {
            [self beginRefreshIsAuto:NO];
        }
    }
}

- (void)beginRefreshIsAuto:(BOOL)isAuto {
    
    if (self.headerRefreshView.animationing) {return;}
    [self.headerRefreshView startAnimation];
    [UIView animateWithDuration:.25 animations:^{
        [self.cyclePageView updateContentInsetTop:HeaderRefreshTop];
        if (isAuto) {
            [self.cyclePageView updateContentOffSetY:-HeaderRefreshTop animation:NO];
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self endRefresh];
                   });
}

- (void)endRefresh {
    [self.headerRefreshView stopAnimation];
    [UIView animateWithDuration:.25 animations:^{
        [self.cyclePageView updateContentInsetTop:0];
    }];
}

@end
