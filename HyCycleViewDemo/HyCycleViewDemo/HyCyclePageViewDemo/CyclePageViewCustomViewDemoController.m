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
#import "CyclePageViewDemoTestController.h"
#import <objc/message.h>


@interface CyclePageViewCustomViewDemoController ()<UICollectionViewDataSource, UICollectionViewDelegate, HyCyclePageViewProviderProtocol>
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

- (void)configCyclePageView:(HyCycleViewProvider<HyCyclePageView *> *)provider index:(NSInteger)index {
    __weak typeof(self) _self = self;
    [provider view:^UIView * _Nonnull(HyCyclePageView * _Nonnull cycleView) {
        __strong typeof(_self) self = _self;
        if (index == 1) {
            return [self collectionView];
        }
        return [self customView];
    }];
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure) {
        
        __weak typeof(self) _self = self;
        
        CGFloat naviHeight = 64;
        if ([[UIApplication sharedApplication].keyWindow respondsToSelector:NSSelectorFromString(@"safeAreaInsets")]) {
            naviHeight = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44;
        }
        CGFloat headerViewH = 250;
        [[[[[[configure hoverViewOffset:naviHeight] loadStyle:HyCycleViewLoadStyleDidAppear] headerViewUpAnimation:HyCyclePageViewHeaderViewUpAnimationCover] headerViewDownAnimation:HyCyclePageViewHeaderViewDownAnimationScale] verticalScrollProgress:^(HyCyclePageView * _Nonnull cyclePageView, UIView * _Nonnull view, NSInteger index, CGFloat offset) {
                __strong typeof(_self) self = _self;
                CGFloat margin = headerViewH - naviHeight;
                if (offset >= margin) {
                    [self.navigationController.navigationBar setAlpha:1.0f];
                }else if (offset < 0) {
                    [self.navigationController.navigationBar setAlpha:.0f];
                }else {
                    [self.navigationController.navigationBar setAlpha:(offset / margin)];
                }
                self.lastAlpha = self.navigationController.navigationBar.alpha;
        }] viewProviderAtIndex:^id<HyCyclePageViewProviderProtocol> _Nonnull(HyCyclePageView * _Nonnull cycleView, NSInteger index) {
            __strong typeof(_self) self = _self;
            if (index == 1 || index == 2) {
                return self;
            }
            if (index == 3) {
                return CyclePageViewTestController.new;
            }
            return CyclePageViewDemoTestController.new;
        }];
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

- (UIView *)customView {
    
    UIView *view = [[UIView alloc] init];
//    view.sizeValue(self.view.width, self.view.height - ([[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44 + 100));
    view.sizeValue(self.view.width, 400);
    view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.text = @"testCustomView";
    [testLabel sizeToFit];
    testLabel.centerXValue(view.width / 2).centerYValue(view.height / 2);
    [view addSubview:testLabel];
    
    return view;
}

- (UICollectionView *)collectionView {
    
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
