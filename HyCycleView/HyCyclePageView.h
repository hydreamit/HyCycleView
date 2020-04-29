//
//  HyCyclePageView.h
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/15.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HyCycleView.h"


/// gesture style(内部手势处理方式)
typedef NS_ENUM(NSUInteger, HyCyclePageViewGestureStyle) {
    /// only gesture(一个手势,不需解决手势冲突)
    HyCyclePageViewGestureStyleOnly,
    /// multiple gestures(多个手势,需解决手势冲突)
    HyCyclePageViewGestureStyleMultiple
};

typedef NS_ENUM(NSUInteger, HyCyclePageViewHeaderViewUpAnimation) {
    /// UpAnimationNone
    HyCyclePageViewHeaderViewUpAnimationNone,
    /// UpAnimationCover
    HyCyclePageViewHeaderViewUpAnimationCover
};

typedef NS_ENUM(NSUInteger, HyCyclePageViewHeaderViewDownAnimation) {
    /// DownAnimationNone
    HyCyclePageViewHeaderViewDownAnimationNone,
    /// AnimationScale
    HyCyclePageViewHeaderViewDownAnimationScale
};

typedef NS_ENUM(NSUInteger, HyCyclePageViewHeaderRefreshStyle) {
    /// top refresh
    HyCyclePageViewHeaderRefreshStyleTop,
    /// center refresh
    HyCyclePageViewHeaderRefreshStyleCenter
};


@class HyCyclePageView;
@interface HyCyclePageViewConfigure : NSObject

/// currentPage
@property (nonatomic,assign,readonly) NSInteger currentPage;
@property (nonatomic,weak,readonly) HyCyclePageView *cyclePageView;

/// gesture Style(需要悬停嵌套scrollView时的 手势处理方式)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^gestureStyle)(HyCyclePageViewGestureStyle);
/// header refresh style
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^headerRefreshStyle)(HyCyclePageViewHeaderRefreshStyle);



/// header view (头部视图)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^headerView)(UIView *);
/// header view height (头部视图高度)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^headerViewHeight)(CGFloat);
/// header view up Animation(头部视图上滑动画)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^headerViewUpAnimation)(HyCyclePageViewHeaderViewUpAnimation);
/// header view down Animation(头部视图下拉动画)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^headerViewDownAnimation)(HyCyclePageViewHeaderViewDownAnimation);


/// hover view (悬停视图)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^hoverView)(UIView *);
/// hover view (悬停视图高度)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^hoverViewHeight)(CGFloat);
/// hover offset default 0 (悬停位置偏移量 默认为0)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^hoverOffset)(CGFloat);

/// cycle page loop default yes (是否为无限循环 默认为YES)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^isCycleLoop)(BOOL);
/// start page (开始页)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^startPage)(NSInteger);
/// total Pages (总页数)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^totalPage)(NSInteger);


/// cycle page view load style (view/Controller加载方式: 滑动出现立即加载/滑动到整个页面再加载)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^loadStyle)(HyCycleViewScrollLoadStyle);
/// cycle views/controllers of class (传入的是class)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^cyclePageClass)(Class (^)(HyCyclePageView *cyclePageView, NSInteger index));
/// cycle page views/controllers (传入的是实例对象)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^cyclePageInstance)(id (^)(HyCyclePageView *cyclePageView, NSInteger index));


/// one page view will appear callback (view 即将出现的回调)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^viewWillAppear)(id (^)(HyCyclePageView *cyclePageView, id pageView, NSInteger index, BOOL isFirstLoad));
/// totalPage and currentPage change (总页/当前页发生改变的回调)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^currentPageChange)(id (^)(HyCyclePageView *cyclePageView, NSInteger indexs, NSInteger index));
/// totalPage and roundingPage change (总页/当前页(四舍五入)发生改变的回调)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^roundingPageChange)(id (^)(HyCyclePageView *cyclePageView, NSInteger indexs, NSInteger index));


/// horizontal scroll progress (水平滑动进度的回调)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^horizontalScroll)(void (^)(HyCyclePageView *cyclePageView, NSInteger fromIndex, NSInteger toIndex, CGFloat progress));
/// vertical scroll  (上下滑动的回调)
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^verticalScroll)(void (^)(HyCyclePageView *cyclePageView, CGFloat offsetY, NSInteger index));

@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^horizontalScrollState)(void (^)(HyCyclePageView *cyclePageView, BOOL isStart));


/// header refresh
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^headerRefresh)(void (^)(HyCyclePageView *cyclePageView, UIScrollView *scrollView, NSInteger index));
/// footer refresh
@property (nonatomic,copy,readonly) HyCyclePageViewConfigure *(^footerRefresh)(void (^)(HyCyclePageView *cyclePageView, UIScrollView *scrollView, NSInteger index));

@end


@interface HyCyclePageView : UIView

/**
 create cyclePageView
 
 @param frame frame
 @param configureBlock config the params
 @return HyCyclePageView
 */
+ (instancetype)cyclePageViewWithFrame:(CGRect)frame
                        configureBlock:(void (^)(HyCyclePageViewConfigure *configure))configureBlock;


/// configure
@property (nonatomic, strong, readonly) HyCyclePageViewConfigure *configure;


/**
 scroll to next page
 
 @param animated animated
 */
- (void)scrollToNextPageWithAnimated:(BOOL)animated;


/**
 scroll to last page
 
 @param animated animated
 */
- (void)scrollToLastPageWithAnimated:(BOOL)animated;


/**
 scroll to the page
 
 @param page page
 @param animated animated
 */
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;


/**
 reload initialize configure block
 */
- (void)reloadConfigureBlock;


/**
 changed configure with reload
 */
- (void)reloadConfigureChange;


/**
 reload headerView or hoverView
 */
- (void)reloadHeaderViewAndHoverView;


/**
 updateContentInsetTop
 
 @param top inset top
 */
- (void)updateContentInsetTop:(CGFloat)top;


/**
 updateContentOffSetY
 
 @param contentOffsetY contentOffset y
 @param flag animation
 */
- (void)updateContentOffSetY:(CGFloat)contentOffsetY
                   animation:(BOOL)flag;

@end


