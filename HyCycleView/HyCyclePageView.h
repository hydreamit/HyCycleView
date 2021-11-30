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


/// 向上滚动头部动画
typedef NS_ENUM(NSUInteger, HyCyclePageViewHeaderViewUpAnimation) {
    HyCyclePageViewHeaderViewUpAnimationNone,
    HyCyclePageViewHeaderViewUpAnimationCover
};

/// 向下滚动头部动画
typedef NS_ENUM(NSUInteger, HyCyclePageViewHeaderViewDownAnimation) {
    HyCyclePageViewHeaderViewDownAnimationNone,
    HyCyclePageViewHeaderViewDownAnimationScale
};

/// 刷新位置
typedef NS_ENUM(NSUInteger, HyCyclePageViewHeaderRefreshPosition) {
    HyCyclePageViewHeaderRefreshPositionTop,
    HyCyclePageViewHeaderRefreshPositionCenter
};


/// 内容模式(当内容数据不够铺满时）
typedef NS_ENUM(NSUInteger, HyCyclePageViewContentMode) {
    HyCyclePageViewContentModeDefault,
    HyCyclePageViewContentModeExpandToFill
};


NS_ASSUME_NONNULL_BEGIN
@class HyCyclePageView;

/// 滚动监听协议
@protocol HyCyclePageViewScrollProgressProtocol <NSObject>
@optional
@property (nonatomic,copy,readonly) void(^hy_horizontalScrollProgress)(HyCyclePageView *cyclePageView, NSInteger fromIndex, NSInteger toIndex, CGFloat progress);
@property (nonatomic,copy,readonly) void(^hy_verticalScrollProgress)(HyCyclePageView *cyclePageView, UIView *view, NSInteger index, CGFloat offset);
@end


@protocol HyCyclePageViewProviderProtocol <NSObject>
- (void)configCyclePageView:(HyCycleViewProvider<HyCyclePageView *> *)provider index:(NSInteger)index;
@end


@interface HyCyclePageViewConfigure : HyCycleViewConfigure<HyCyclePageView *,
                                                        id<HyCyclePageViewProviderProtocol>>
/// 头部视图
- (instancetype)headerView:(UIView *)view;
/// 头部视图高度
- (instancetype)headerViewHeight:(CGFloat)height;
/// 头部视图向上滑动动画
- (instancetype)headerViewUpAnimation:(HyCyclePageViewHeaderViewUpAnimation)animation;
/// 头部视图向下滑动动画
- (instancetype)headerViewDownAnimation:(HyCyclePageViewHeaderViewDownAnimation)animation;

/// 悬停视图
- (instancetype)hoverView:(UIView *)view;
/// 悬停视图高度
- (instancetype)hoverViewHeight:(CGFloat)height;
/// 悬停偏移量
- (instancetype)hoverViewOffset:(CGFloat)offset;

/// 内容模式(默认： HyCyclePageViewContentModeExpandToFill)
- (instancetype)contentMode:(HyCyclePageViewContentMode)mode;

/// 垂直滑动回调
- (instancetype)verticalScrollProgress:(void(^)(HyCyclePageView *cyclePageView, UIView *view, NSInteger index, CGFloat offset))block;

/// 头部刷新位置
- (instancetype)headerRefreshPositon:(HyCyclePageViewHeaderRefreshPosition)positon;
/// 头部刷新设置
- (instancetype)headerRefreshAtIndex:(void(^)(HyCyclePageView *cyclePageView, UIScrollView *scrollView, id view, NSInteger index))block;
/// 尾部刷新设置
- (instancetype)footerRefreshAtIndex:(void(^)(HyCyclePageView *cyclePageView, UIScrollView *scrollView, id view, NSInteger index))block;

@end



@interface HyCyclePageView : UIView

/// 配置
@property (nonatomic, strong, readonly) HyCyclePageViewConfigure *configure;


/// 头部视图
@property (nonatomic, strong, readonly) UIView *headerView;
/// 悬停视图
@property (nonatomic, strong, readonly) UIView *hoverView;
/// 当前下标
@property (nonatomic, assign, readonly) NSInteger currentIndex;
/// 当前可见视图
@property (nonatomic, strong, readonly) NSArray<UIView *> *visibleViews;
/// 当前可见视图的下标
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *visibleIndexs;
/// 已经加载过的下标
@property (nonatomic, strong, readonly) NSIndexSet *didLoadIndexs;
/// 根据下标去获取对应的视图，没加载过的返回nil
@property (nonatomic, copy, readonly, nullable) UIView *(^viewAtIndex)(NSInteger);


/// 刷新整个视图
- (void)reloadData;
/// 刷新某个视图
- (void)reloadDataAtIndex:(NSInteger)index parameter:(id _Nullable)parameter;

/// 是否能水平滚动
- (void)setScrollEnabled:(BOOL)flag;

/// 跟新contentInset.top
- (void)updateContentInsetTop:(CGFloat)top;

/// 跟新ContentOffSet.y
- (void)updateContentOffSetY:(CGFloat)contentOffsetY
                   animation:(BOOL)flag;


/// 滚动到下一页
/// @param animated 是否动画
- (void)scrollToNextIndexWithAnimated:(BOOL)animated;

/// 滚动到上一页
/// @param animated 是否动画
- (void)scrollToLastIndexWithAnimated:(BOOL)animated;

/// 滚动到指定页
/// @param index 指定下标
/// @param animated 是否动画
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;


@end


NS_ASSUME_NONNULL_END
