//
//  HYCycleView.h
//  ScrollView
//
//  Created by jsb06 on 16/5/3.
//  Copyright © 2016年 jsb06. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HYCycleViewTimerStart, // 自动轮播模式
    HYCycleViewTimerStop 
} HYCycleViewTimerStyle;

typedef enum {             // 滚动方向
    HYCycleViewScrollLeft,
    HYCycleViewScrollRight,
    HYCycleViewScrollTop,
    HYCycleViewScrollBottom,
} HYCycleViewScrollDirection;

@class HYCycleView;

@protocol HYCycleViewDelegate <NSObject>
@optional
- (void)cycleView:( HYCycleView * _Nonnull )cycleView didSelectAtIndex:(NSInteger)index;
@end

@interface HYCycleView : UIView

/**
 *  公有属性
 */
@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (nonatomic, assign) NSTimeInterval timeInterval; // 轮播模式间隔时间，默认2秒
@property (nonatomic, assign) HYCycleViewScrollDirection scrollDirection; // 滚动方向
@property (nonatomic, weak) id<HYCycleViewDelegate> delegate;



/**
 *  默认ImageView
 *
 */
@property (nonatomic, strong) NSArray *NetImageUrlArray;
@property (nonatomic, strong) NSArray *localImageNameArray;
@property (nonatomic, assign) UIViewContentMode imageViewContentMode; // 设置图片内容模式
+ (instancetype)CycleViewWithFrame:(CGRect)frame localImageNameArray:(NSArray *)localImageNameArray  timerStyle:(HYCycleViewTimerStyle)timerStlye; // 本地图片图片
+ (instancetype)CycleViewWithFrame:(CGRect)frame NetImageUrlArray:(NSArray *)NetImageUrlArray placeholderImage:(NSString *)placeholderImage timerStyle:(HYCycleViewTimerStyle)timerStlye; // 网络图片


/**
 *  自定义控件
 *
 */
@property (nonatomic, strong) NSArray *models;
+ (instancetype)CycleViewWithFrame:(CGRect)frame contentViewClass:(nullable Class)contentViewClass models:(NSArray *)models timerStyle:(HYCycleViewTimerStyle)timerStlye;
+ (instancetype)CycleViewWithFrame:(CGRect)frame contentViewNibName:(NSString *)nibName models:(NSArray *)models timerStyle:(HYCycleViewTimerStyle)timerStlye; //Xib中加载

/**************************** 自定义控件数据的赋值 **************************/

/************** 1. 最简单方试 ***************/
 
/**
 *  在自定义控件中直接实现这个方法，可先在自定义的.m文件里#import "HYCycleView.h", 提示写出这个方法， 最后可把#import "HYCycleView.h"删去, 让contentView更加独立性。
 *
 *  @param model contentView对应的数据模型；
 */
- (void)setModel:(id)model;


/************** 2.习惯方式:创建模型属性（默认名：model）(可直接打出set方法)，实现set方法 ***************/

// 根据你自己情况，取的模型属性名不叫model, 可在contentView的.m文件里实现这个方法， 返回自己设定的方法名。
/**
 *  重置contentView模型属性名, 可先在自定义的.m文件里#import "HYCycleView.h", 提示写出这个方法， 最后可把#import "HYCycleView.h"删去, 让contentView更加独立性。
 *
 *  @return contentView传入模型属性名(默认名:model, 如果传入属性名叫model就不用再自定义控件中实现这个方法)
 */
- (NSString *)SetupContentModelName;
@end
