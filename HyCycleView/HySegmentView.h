//
//  HySegmentView.h
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/22.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HySegmentViewItemPosition) {
    HySegmentViewItemPositionLeft,
    HySegmentViewItemPositionCenter,
    HySegmentViewItemPositionRight
};

@class HySegmentView;
@interface HySegmentViewConfigure : NSObject

/// get current index
- (NSInteger)getCurrentIndex;
/// get inset
- (UIEdgeInsets)getInset;
/// get item margin
- (CGFloat)getItemMargin;

/// inset (内边距)
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^inset)(UIEdgeInsets);

/// insetAndMarginRatio (左右变局和中间间隔的比例)
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^insetAndMarginRatio)(CGFloat);

///item margin default average (标签间距 默认是平均分配, 不够分默认值30)
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^itemMargin)(CGFloat);

/// keeping margin and inset default NO (是否保持margin/inset不变(外部自定义itemView变化时))
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^keepingMarginAndInset)(BOOL);

/// start index default 0 (开始选中的标签数)
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^startIndex)(NSInteger);

///number of items （标签总数)
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^numberOfItems)(NSInteger);

/// click item at index callback(点击回调 返回YES内部实现点击动画逻辑, NO外部自己通过调用方法clickItemFromIndex:实现)
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^clickItemAtIndex)(BOOL(^)(NSInteger index, BOOL isRepeat));

/// view for item at index
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^viewForItemAtIndex)(UIView *(^)(UIView *currentView, NSInteger index, CGFloat progress, HySegmentViewItemPosition position, NSArray<UIView *> *animationViews));

/// animationViews
@property (nonatomic, copy, readonly) HySegmentViewConfigure *(^animationViews)(NSArray<UIView *> *(^)(NSArray<UIView *> *currentAnimationViews, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress));

@end

@interface HySegmentView : UIView


/**
 create HySegmentView
 
 @param frame frame
 @param configureBlock config the params
 @return HySegmentView
 */
+ (instancetype)segmentViewWithFrame:(CGRect)frame
                      configureBlock:(void (^)(HySegmentViewConfigure *configure))configureBlock;


/// configure
@property (nonatomic,strong,readonly) HySegmentViewConfigure *configure;



/**
 click item at index
 
 @param index clicking index
 */
- (void)clickItemAtIndex:(NSInteger)index;



/**
 click item with progress
 
 @param fromIndex fromIndex
 @param toIndex toIndex
 @param progress progress
 */
- (void)clickItemFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
                  progress:(CGFloat)progress;


/**
 reload initialize configure block
 */
- (void)reloadConfigureBlock;


/**
 changed configure with reload
 */
- (void)reloadConfigureChange;


@end


