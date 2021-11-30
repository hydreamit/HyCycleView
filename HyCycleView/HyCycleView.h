//
//  HyCycleView.h
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 16/5/3.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HyCycleView;

NS_ASSUME_NONNULL_BEGIN

/// 加载方式
typedef NS_ENUM(NSUInteger, HyCycleViewLoadStyle) {
    HyCycleViewLoadStyleWillAppear,
    HyCycleViewLoadStyleDidAppear
};

/// 滚动方向
typedef NS_ENUM(NSUInteger, HyCycleViewDirection) {
    HyCycleViewDirectionLeft,
    HyCycleViewDirectionRight,
    HyCycleViewDirectionTop,
    HyCycleViewDirectionBottom
};

@class HyCycleView;
@protocol HyCycleViewScrollDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView cycleView:(HyCycleView *)cycleView;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView cycleView:(HyCycleView *)cycleView;
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset cycleView:(HyCycleView *)cycleView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate cycleView:(HyCycleView *)cycleView;
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView cycleView:(HyCycleView *)cycleView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView cycleView:(HyCycleView *)cycleView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView cycleView:(HyCycleView *)cycleView;
@end


/// 刷新数据协议 自定义分页view遵循 当HyCycleView实例调用 reloadDataAtIndex:parameter:会回调协议里的方法
@protocol HyCycleViewReloadDataProtocol <NSObject>
@optional
- (void)cycleViewReloadDataAtIndex:(NSInteger)index parameter:(id _Nullable)parameter;
@end


@interface HyCycleViewProvider<__covariant CycleViewType> : NSObject
/// 是否引用数据源对象(已被其他对象引用不用设)
@property (nonatomic,assign) BOOL retainProvider;
/// 视图
- (instancetype)view:(UIView *(^)(CycleViewType cycleView))block;
/// 视图即将出现回调
- (instancetype)viewWillAppear:(void(^)(CycleViewType cycleView, id view, BOOL isFirstLoad))block;
/// 视图消失完成回调
- (instancetype)viewDidDisAppear:(void(^)(CycleViewType cycleView, id view))block;
/// 点击事件回调
- (instancetype)viewClickAction:(void(^)(CycleViewType cycleView, id view))block;
///  reloadDataAtIndex:parameter:： 事件回调
- (instancetype)viewReloadData:(void(^)(CycleViewType cycleView, id view, id _Nullable parameter))block;
@end
@protocol HyCycleViewProviderProtocol <NSObject>
- (void)configCycleView:(HyCycleViewProvider<HyCycleView *> *)provider index:(NSInteger)index;
@end


@interface HyCycleViewConfigure<__covariant CycleViewType,
                                __covariant CycleViewProviderProtocolType> : NSObject

/// 是否无限循环 默认NO
- (instancetype)isCycle:(BOOL)isCycle;
/// 是否自动轮播 默认NO
- (instancetype)isAutoCycle:(BOOL)isAutoCycle;
/// 自动轮播时间间隔
- (instancetype)interval:(NSTimeInterval)interval;
/// 数据展示方向
- (instancetype)direction:(HyCycleViewDirection)direction;
/// 页面加载时机
- (instancetype)loadStyle:(HyCycleViewLoadStyle)loadStyle;
/// 开始页
- (instancetype)startIndex:(NSInteger (^)(CycleViewType cycleView))block;
/// 总页数
- (instancetype)totalIndexs:(NSInteger (^)(CycleViewType cycleView))block;
/// 视图提供源
- (instancetype)viewProviderAtIndex:(CycleViewProviderProtocolType(^)(CycleViewType cycleView, NSInteger index))block;
/// 视图即将出现回调
- (instancetype)viewWillAppearAtIndex:(void(^)(CycleViewType cycleView, id view, NSInteger index, BOOL isFirstLoad))block;
/// 视图消失完成回调
- (instancetype)viewDidDisAppearAtIndex:(void(^)(CycleViewType cycleView, id view, NSInteger index))block;
/// 点击事件回调
- (instancetype)clickActionAtIndex:(void(^)(CycleViewType cycleView, id view, NSInteger index))block;
/// 当前页改变回调
- (instancetype)currentIndexChange:(void(^)(CycleViewType cycleView, NSInteger indexs, NSInteger index))block;
/// 四舍五入页改变回调
- (instancetype)roundingIndexChange:(void(^)(CycleViewType cycleView, NSInteger indexs, NSInteger roundingIndex))block;
/// 滚动回调
- (instancetype)scrollProgress:(void(^)(CycleViewType cycleView, NSInteger fromIndex, NSInteger toIndex, CGFloat progress))block;
/// 滚动代理
- (instancetype)scrollDelegate:(id<HyCycleViewScrollDelegate>)delegate;
@end



@interface HyCycleView : UIView

/// 配置
@property (nonatomic, strong, readonly) HyCycleViewConfigure<HyCycleView *,
                                                          id<HyCycleViewProviderProtocol>> *configure;

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
