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
    [self beginRefreshIsAuto:YES];
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    __weak typeof(self) _self = self;
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        
        [[[configure headerRefreshPositon:HyCyclePageViewHeaderRefreshPositionTop] footerRefreshAtIndex:^(HyCyclePageView * _Nonnull cyclePageView, UIScrollView * _Nonnull scrollView, id  _Nonnull view, NSInteger index) {
            
            __block typeof(scrollView) weakScrollView = scrollView;
            scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(.5 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    [weakScrollView.mj_footer endRefreshing];
                });
            }];
        }] verticalScrollProgress:^(HyCyclePageView * _Nonnull cyclePageView, UIView * _Nonnull view, NSInteger index, CGFloat offset) {
            __strong typeof(_self) self = _self;            
            if (offset < - 20 && !self.headerRefreshView.animationing) {
                self.headerRefreshView.progress = - (offset + 20) / (HeaderRefreshTop - 20);
            }
        }];
    };
}

- (UIView *)headerView {
    
    UIView *superHeaderView = [super headerView];
    self.headerRefreshView =
    [[CircleRefreshView alloc] initWithFrame:CGRectMake((superHeaderView.width - 30) / 2, - 40, 30, 30)];
    [superHeaderView addSubview:self.headerRefreshView];
    return superHeaderView;
}

- (void (^)(UIScrollView *))scrollViewDidEndDragging {
    __weak typeof(self) _self = self;
    return ^(UIScrollView *scrollView) {
        __strong typeof(_self) self = _self;
        if (!self.headerRefreshView.animationing) {
            CGFloat height = HeaderRefreshTop + 250 + 40;
            if (scrollView.contentOffset.y < - height) {
                [self beginRefreshIsAuto:NO];
            }
        }
    };
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
                                 (int64_t)(2 * NSEC_PER_SEC)),
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
