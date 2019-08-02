//
//  CyclePageViewCustomViewDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewCustomViewDemoController.h"
#import "CyclePageViewTestController.h"
#import <objc/message.h>


@interface CyclePageViewCustomViewDemoController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) CGFloat lastAlpha;
@end


@implementation CyclePageViewCustomViewDemoController
@dynamic scrollView;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.navigationController.navigationBar setAlpha:self.lastAlpha];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setAlpha:1.f];
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure) {
        
        __weak typeof(self) weakSelf = self;
        
        CGFloat naviHeight = 64;
        if ([[UIApplication sharedApplication].keyWindow respondsToSelector:NSSelectorFromString(@"safeAreaInsets")]) {
            naviHeight = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44;
        }
        
        CGFloat headerViewH = 250;
        
        configure
        .hoverOffset(naviHeight)
        .loadStyle(HyCycleViewScrollLoadStyleDidAppear)
        .headerViewUpAnimation(HyCyclePageViewHeaderViewUpAnimationCover)
        .headerViewDownAnimation(HyCyclePageViewHeaderViewDownAnimationScale)
        .cyclePageInstance(^id(HyCyclePageView *pageView, NSInteger currentPage){
            
            if (currentPage == 1) {
                return [weakSelf createCollectionView];
            } else if (currentPage == 2) {
                return [[CyclePageViewTestController alloc] init];
            } else {
                return
                ((id (*)(id, SEL, NSInteger))objc_msgSend)(weakSelf, NSSelectorFromString(@"creatTableViewWithPageNumber:"), currentPage);
            }
        })
        .verticalScroll(^(HyCyclePageView *cyclePageView,
                          CGFloat offsetY,
                          NSInteger currentPage){
            
            CGFloat margin = headerViewH - naviHeight;
            if (offsetY >= margin) {
                [weakSelf.navigationController.navigationBar setAlpha:1.0f];
            }else if (offsetY < 0) {
                [weakSelf.navigationController.navigationBar setAlpha:.0f];
            }else {
                [weakSelf.navigationController.navigationBar setAlpha:(offsetY / margin)];
            }
            weakSelf.lastAlpha = weakSelf.navigationController.navigationBar.alpha;
        });
    };
}

- (UIView *)hoverView {
    
    UIView *view = [super hoverView];
    
    UIView *newHoverView = [[UIView alloc] init];
    newHoverView.backgroundColor = UIColor.whiteColor;
    newHoverView.widthIsEqualTo(view).heightValue(100);
    
    UIView *customTopView = [[UIView alloc] init];
    customTopView.backgroundColor = UIColor.orangeColor;
    customTopView.rectValue(0, 0, view.width, 30);
    [newHoverView addSubview:customTopView];
    
    [newHoverView addSubview:view];
    view.topValue(customTopView.bottom);
    
    
    UIView *customBottomView = [[UIView alloc] init];
    customBottomView.backgroundColor = UIColor.orangeColor;
    customBottomView.rectValue(0, view.bottom, view.width, 30);
    [newHoverView addSubview:customBottomView];
    
    return newHoverView;
}

- (UICollectionView *)createCollectionView {
    
    CGFloat itemWH = (self.view.width - 6 * 10) / 5;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (@available(iOS 10.0, *)) {
        collectionView.prefetchingEnabled = NO;
    }
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class)
                                              forIndexPath:indexPath];
    cell.backgroundColor = UIColor.grayColor;
    return cell;
}

@end
