//
//  HySegmentView.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/22.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HySegmentView.h"
#import "UIView+HyFrame.h"

@interface HySegmentViewConfigure ()

@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,assign) CGFloat hy_itemMargin;
@property (nonatomic,assign) NSInteger hy_items;
@property (nonatomic,assign) NSInteger hy_startIndex;

@property (nonatomic,copy) void(^hy_clickItemAtIndex)(NSInteger, BOOL);

@property (nonatomic,copy) UIView *(^hy_viewForItemAtIndex)(UIView *,
                                                            NSInteger,
                                                            CGFloat,
                                                            HySegmentViewItemPosition,
                                                            NSArray<UIView *> *);

@property (nonatomic,copy) NSArray<UIView *> *(^hy_animationViews)(NSArray<UIView *> *views,
                                                                  UICollectionViewCell *,
                                                                  UICollectionViewCell *,
                                                                  NSInteger,
                                                                  NSInteger,
                                                                  CGFloat);
+ (instancetype)defaultConfigure;
@property (nonatomic,weak) HySegmentView *segmentView;
@end



@interface HySegmentView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@property (nonatomic,strong) HySegmentViewConfigure *configure;
@property (nonatomic,assign) NSInteger currentSelectedIndex;
@property (nonatomic,strong) NSMutableArray<UIView *> *itemViews;
@property (nonatomic,strong) NSMutableArray<UIView *> *animationViews;
@end


@implementation HySegmentView

+ (instancetype)segmentViewWithFrame:(CGRect)frame
                      configureBlock:(void (^)(HySegmentViewConfigure *configure))configureBlock {
    
    HySegmentView *segmentView = [[self alloc] initWithFrame:frame];
    segmentView.backgroundColor = UIColor.whiteColor;
    !configureBlock ?: configureBlock(segmentView.configure);
    segmentView.configure.segmentView = segmentView;
    if (segmentView.configure.hy_startIndex < segmentView.configure.hy_items) {
        segmentView.currentSelectedIndex = segmentView.configure.hy_startIndex;
    }
    [segmentView addSubview:segmentView.collectionView];
    return segmentView;
}

- (void)handleLayout {
   
    if (self.configure.hy_viewForItemAtIndex) {
        
        [self.itemViews removeAllObjects];
        
        CGFloat totalWith = 0.0;
        for (NSInteger i = 0; i < self.configure.hy_items; i++) {
            UIView *view = self.configure.hy_viewForItemAtIndex(nil, i, 0, HySegmentViewItemPositionCenter, nil);
            if (view) {
                totalWith += view.size.width;
                [self.itemViews addObject:view];
            }
        }
        
        if (self.configure.hy_itemMargin == 0) {
            CGFloat overWith = self.width - totalWith;
            if (overWith >= 0) {
                self.configure.hy_itemMargin = overWith / (self.configure.hy_items + 1);
            } else {
                self.configure.hy_itemMargin = 30;
            }
        }
    }
}

- (void)clickItemAtIndex:(NSInteger)index {
    
    if (index < self.configure.hy_items && index != self.currentSelectedIndex) {
        [self handleAnimationViewWithFromIndex:self.currentSelectedIndex
                                       toIndex:index
                                      progress:1];
    }
}

- (void)clickItemFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
                  progress:(CGFloat)progress {
    
    if (fromIndex < self.configure.hy_items && toIndex < self.configure.hy_items) {
        [self handleAnimationViewWithFromIndex:fromIndex
                                       toIndex:toIndex
                                      progress:progress];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(.05 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self handleAnimationViewWithFromIndex:self.currentSelectedIndex
                                                      toIndex:self.currentSelectedIndex
                                                     progress:1];
                   });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.containTo(self);
    [self handleLayout];
}

- (void)handleAnimationViewWithFromIndex:(NSInteger)fromIndex
                                 toIndex:(NSInteger)toIndex
                                progress:(CGFloat)progress {
    
    if (progress == 1) {
        self.currentSelectedIndex = toIndex;
    }
    
    UICollectionViewCell *fromCell = [self getCellWithIndex:fromIndex];
    UICollectionViewCell *toCell = [self getCellWithIndex:toIndex];
    
    if (self.configure.hy_animationViews) {
        
        NSArray<UIView *> *animationViews =
        self.configure.hy_animationViews(self.animationViews, fromCell, toCell, fromIndex, toIndex, progress);
        
        if (![self checkAnimationViews:animationViews]) {
            
            [self.collectionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:UICollectionViewCell.class]) {
                    [obj removeFromSuperview];
                }
            }];
            
            for (UIView *view in animationViews) {
                [self.collectionView insertSubview:view atIndex:0];
            }
            self.animationViews = animationViews.mutableCopy;
        }
    }
    
    if (toIndex != fromIndex) {
        
        HySegmentViewItemPosition position = HySegmentViewItemPositionCenter;
        if (progress != 0 && progress != 1 && fromIndex != toIndex) {
            if (fromIndex == self.currentSelectedIndex) {
                if (fromIndex < toIndex) {
                    position = HySegmentViewItemPositionRight;
                } else {
                    position = HySegmentViewItemPositionLeft;
                }
            } else {
                if (fromIndex < toIndex) {
                    position = HySegmentViewItemPositionLeft;
                } else {
                    position = HySegmentViewItemPositionRight;
                }
            }
        }
        
        [self handleItemViewWithCell:fromCell
                               index:fromIndex
                            progress:1 - progress
                            position:position];
        
        [self handleItemViewWithCell:toCell
                               index:toIndex
                            progress:progress
                            position:position];
    }
   
    if (progress == 1) {
        [self scrollToCenterWithIndex:toIndex];
    }
}

- (void)handleItemViewWithCell:(UICollectionViewCell *)cell
                           index:(NSInteger)index
                        progress:(CGFloat)progress
                       position:(HySegmentViewItemPosition)position{
    
    if (self.configure.hy_viewForItemAtIndex) {
        
        UIView *lastItemView = [self getItemViewWithIndex:index];
        
        UIView *currentItemView =
        self.configure.hy_viewForItemAtIndex(lastItemView,
                                             index,
                                             progress,
                                             position,
                                             self.animationViews);
        
        if (currentItemView) {
            if (lastItemView != currentItemView) {
                if (index < self.itemViews.count) {
                   [self.itemViews replaceObjectAtIndex:index withObject:currentItemView];
                }
                [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [cell.contentView addSubview:currentItemView];
            } else {
                if (cell.contentView.subviews.firstObject != currentItemView) {
                    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    [cell.contentView addSubview:currentItemView];
                }
            }
            
            currentItemView.centerYValue(cell.contentView.height / 2);
        }
    }
}

- (void)scrollToCenterWithIndex:(NSInteger)index {
    
    if (self.collectionView.contentSize.width < self.collectionView.width) {
        return;
    }
    
    UICollectionViewLayoutAttributes *layoutAttr =
    [self.layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    CGFloat centerX = layoutAttr.frame.origin.x + layoutAttr.frame.size.width / 2;
    CGFloat offsetX = centerX - self.collectionView.width / 2;
    if (offsetX < 0) { offsetX = 0;}
    
    if (offsetX > self.collectionView.contentSize.width - self.collectionView.width) {
        offsetX = self.collectionView.contentSize.width - self.collectionView.width;
    }
    [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (UIView *)getItemViewWithIndex:(NSInteger)index {
    
    if (index < self.itemViews.count) {
        return self.itemViews[index];
    }
    return nil;
}

- (UICollectionViewCell *)getCellWithIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] initWithFrame:[self.layout layoutAttributesForItemAtIndexPath:indexPath].frame];
    }
    return cell;
}

- (BOOL)checkAnimationViews:(NSArray<UIView *> *)animationViews {
    
    if (animationViews.count != self.animationViews.count) {
        return NO;
    }
    
    __block BOOL isSame = YES;
    [self.animationViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (animationViews[idx] != obj) {
            isSame = NO;
            *stop = YES;
        }
    }];
    return isSame;
}

#pragma mark — UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.configure.hy_items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)
                                              forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = UIColor.clearColor;
    [self handleItemViewWithCell:cell
                           index:indexPath.row
                        progress:self.currentSelectedIndex == indexPath.row
                        position:HySegmentViewItemPositionCenter];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    !self.configure.hy_clickItemAtIndex ?:
    self.configure.hy_clickItemAtIndex(indexPath.row,
                                       indexPath.row == self.currentSelectedIndex);
    
    self.currentSelectedIndex = indexPath.row;
    
//    if (indexPath.row != self.currentSelectedIndex) {
//        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:self.currentSelectedIndex inSection:0];
//        self.currentSelectedIndex = indexPath.row;
//        [collectionView reloadItemsAtIndexPaths:@[selectedIndexPath, indexPath]];
//        [self scrollToCenterWithIndex:indexPath.row];
//    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.itemViews[indexPath.row].width, collectionView.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  
    return self.configure.hy_itemMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, self.configure.hy_itemMargin, 0, self.configure.hy_itemMargin);
}

#pragma mark — getters and setters
- (HySegmentViewConfigure *)configure {
    if (!_configure){
        _configure = [HySegmentViewConfigure defaultConfigure];
    }
    return _configure;
}

- (UICollectionView *)collectionView {
    if (!_collectionView){
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:self.layout];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        if (@available(iOS 10.0, *)) {
            _collectionView.prefetchingEnabled = NO;
        }
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout){
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumInteritemSpacing = 0;
    }
    return _layout;
}

- (NSMutableArray<UIView *> *)itemViews {
    if (!_itemViews){
        _itemViews = @[].mutableCopy;
    }
    return _itemViews;
}
- (NSMutableArray<UIView *> *)animationViews {
    if (!_animationViews){
        _animationViews = @[].mutableCopy;
    }
    return _animationViews;
}

@end

@implementation HySegmentViewConfigure

+ (instancetype)defaultConfigure {
    HySegmentViewConfigure *configure = [[self alloc] init];
    return configure;
}

- (HySegmentViewConfigure *(^)(NSInteger))startIndex {
    return ^HySegmentViewConfigure *(NSInteger index){
        self.hy_startIndex = index;
        return self;
    };
}
- (HySegmentViewConfigure *(^)(NSInteger))numberOfItems {
    return ^HySegmentViewConfigure *(NSInteger items){
        self.hy_items = items;
        return self;
    };
}

- (HySegmentViewConfigure *(^)(CGFloat))itemMargin {
    return ^HySegmentViewConfigure *(CGFloat margin){
        self.hy_itemMargin = margin;
        return self;
    };
}

- (HySegmentViewConfigure *(^)(void (^)(NSInteger,
                                        BOOL)))clickItemAtIndex {
    
    return ^HySegmentViewConfigure *(void (^block)(NSInteger,
                                                   BOOL)){
        self.hy_clickItemAtIndex = [block copy];
        return self;
    };
}


- (HySegmentViewConfigure *(^)(UIView *(^)(UIView *,
                                           NSInteger,
                                           CGFloat,
                                           HySegmentViewItemPosition,
                                           NSArray<UIView *> *)))viewForItemAtIndex {
    return ^HySegmentViewConfigure *(UIView *(^block)(UIView *,
                                                      NSInteger,
                                                      CGFloat,
                                                      HySegmentViewItemPosition,
                                                      NSArray<UIView *> *)){
        self.hy_viewForItemAtIndex = [block copy];
        return self;
    };
}

- (HySegmentViewConfigure *(^)(NSArray<UIView *> *(^)(NSArray<UIView *> *,
                                                      UICollectionViewCell *,
                                                      UICollectionViewCell *,
                                                      NSInteger,
                                                      NSInteger,
                                                      CGFloat)))animationViews {
    
    return ^HySegmentViewConfigure *(NSArray<UIView *> *(^block)(NSArray<UIView *> *,
                                                                 UICollectionViewCell *,
                                                                 UICollectionViewCell *,
                                                                 NSInteger,
                                                                 NSInteger,
                                                                 CGFloat)){
        self.hy_animationViews = [block copy];
        return self;
    };
}

- (NSInteger)currentIndex {
    return self.segmentView.currentSelectedIndex;
}

@end
