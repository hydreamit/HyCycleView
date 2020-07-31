//
//  CyclePageViewTikTokDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewTikTokDemoController.h"
#import "CyclePageViewTikTokHeaderView.h"
#import "CyclePageViewTikTokCell.h"


@interface CyclePageViewTikTokDemoController () <UICollectionViewDataSource, UICollectionViewDelegate, HyCyclePageViewProviderProtocol>
@property (nonatomic,strong) HySegmentView *segmentView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) CGFloat lastAlpha;
@property (nonatomic,strong) UIColor *barTintColor;
@property (nonatomic,strong) UIColor *tintColor;
@end

@implementation CyclePageViewTikTokDemoController
@dynamic segmentView, scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:20.0 / 255 green:25.0/255 blue:35.0/255 alpha:1];
    self.segmentView.backgroundColor = [UIColor colorWithRed:20.0 / 255 green:25.0/255 blue:35.0/255 alpha:1];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.barTintColor = self.navigationController.navigationBar.barTintColor;
    self.tintColor = self.navigationController.navigationBar.tintColor;
    self.navigationController.navigationBar.barTintColor = self.segmentView.backgroundColor;
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationController.navigationBar.translucent = NO;

    [self.navigationController.navigationBar setAlpha:self.lastAlpha];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.navigationController.navigationBar.barTintColor = self.barTintColor;
    self.navigationController.navigationBar.tintColor = self.tintColor;
    self.navigationController.navigationBar.translucent = YES;
    
    [self.navigationController.navigationBar setAlpha:1];
}

- (NSArray<NSString *> *)titleArray {
    return @[@"作品 888", @"动态 666", @"喜欢 9999"];
}

- (void)configCyclePageView:(HyCycleViewProvider<HyCyclePageView *> *)provider index:(NSInteger)index {
    __weak typeof(self) _self = self;
    [provider view:^UIView * _Nonnull(HyCyclePageView * _Nonnull cycleView) {
        __strong typeof(_self) self = _self;
        return [self collectionView];
    }];
}

- (UIView *)headerView {
     CyclePageViewTikTokHeaderView *headerView = [[CyclePageViewTikTokHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 390)];
    return headerView;
}


- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    
    CGFloat naviHeight = 64;
    if ([[UIApplication sharedApplication].keyWindow respondsToSelector:NSSelectorFromString(@"safeAreaInsets")]) {
        naviHeight = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44;
    }
    
    CGFloat headerViewH = 360;
    __weak typeof(self) _self = self;
   
    return ^(HyCyclePageViewConfigure * _Nonnull configure) {
        
        [[[configure hoverViewOffset:naviHeight] verticalScrollProgress:^(HyCyclePageView * _Nonnull cyclePageView, UIView * _Nonnull view, NSInteger index, CGFloat offset) {
            
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
            return self;
        }];
    };
}

- (void (^)(HySegmentViewConfigure * _Nonnull))configSegmentView {
    __weak typeof(self) _self = self;
    return ^(HySegmentViewConfigure * _Nonnull configure) {
        configure
        .itemMargin(MAXFLOAT)
        .insetAndMarginRatio(.65)
        .viewForItemAtIndex(^UIView *(UIView *currentView,
                                      NSInteger currentIndex,
                                      CGFloat progress,
                                      HySegmentViewItemPosition position,
                                      NSArray<UIView *> *animationViews) {
            
               __strong typeof(_self) self = _self;
               UILabel *label = (UILabel *)currentView;
               if (!label) {
                   label = [UILabel new];
                   label.text = self.titleArray[currentIndex];
                   label.textAlignment = NSTextAlignmentCenter;
                   [label sizeToFit];
               }
               if (progress == 0 || progress == 1) {
                   label.textColor =  progress == 0 ? [UIColor colorWithWhite:1 alpha:.5] : [UIColor colorWithWhite:1 alpha:1];
               }
            return label;
        })
        .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                 __strong typeof(_self) self = _self;
                 NSArray<UIView *> *array = currentAnimations;
                 if (!array.count) {
                     UIView *line = [UIView new];
                     line.backgroundColor = UIColor.orangeColor;
                     line.sizeValue(self.view.width / 3 * .8, 3).bottomValue(40);
                     array = @[line];
                 }
                 array.firstObject.centerXValue((1 - progress) * fromCell.centerX + progress * toCell.centerX);
                 return array;
         });
    };
}


- (UICollectionView *)collectionView {
    
    CGFloat itemWH = (self.view.width - 2) / 3;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
    [collectionView registerClass:[CyclePageViewTikTokCell class] forCellWithReuseIdentifier:NSStringFromClass(CyclePageViewTikTokCell.class)];
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
    
    CyclePageViewTikTokCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(CyclePageViewTikTokCell.class)
                                              forIndexPath:indexPath];
    NSArray<NSString *> *images = @[@"one", @"two", @"three"];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row % 3]];
    return cell;
}
 
@end
