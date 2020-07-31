//
//  CyclePageViewBaseDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewBaseDemoController.h"
#import "CyclePageViewDemoTestController.h"
#import "CyclePageViewHeaderView.h"
#import <MJRefresh/MJRefresh.h>
#import "CyclePageViewTikTokHeaderView.h"


@interface CyclePageViewBaseDemoController () <HyCycleViewProviderProtocol>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) HyCycleView *cycleView;
@property (nonatomic,strong) HySegmentView *segmentView;
@property (nonatomic,strong) HyCyclePageView *cyclePageView;
@property (nonatomic,strong) NSArray<NSString *> *titleArray;
@property (nonatomic,strong) NSArray<UIColor *> *colorArray;
@end


@implementation CyclePageViewBaseDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.titleArray = @[@"NBA", @"国际足球", @"中国篮球", @"跑步",@"欧洲杯", @"欧冠" ,@"英超", @"西甲", @"意甲"];
    [self.view addSubview:self.scrollView];
    [self.cyclePageView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cyclePageView.heightValue(self.scrollView.height - self.scrollView.adjustedContentInset.top);
}

- (UIView *)hoverView {
    return self.segmentView;
}

- (UIView *)headerView {
    CyclePageViewHeaderView *headerView = [[CyclePageViewHeaderView alloc] init];
    headerView.size = CGSizeMake(self.view.width, 250);
    return headerView;
}

- (void (^)(HyCyclePageViewConfigure *))configPageView {
    return nil;
}

- (void (^)(HySegmentViewConfigure *))configSegmentView {
    return nil;
}

#pragma mark — HyCycleViewProviderProtocol
- (void)configCycleView:(HyCycleViewProvider<HyCycleView *> *)provider index:(NSInteger)index {
    NSArray *imageArray = @[@"one",@"two",@"three",@"four"];
    [provider view:^UIView * _Nonnull(HyCycleView * _Nonnull cycleView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:imageArray[index]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        return imageView;
    }];
}

#pragma mark — getters and setters
- (UIScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView addSubview:self.cyclePageView];
    }
    return _scrollView;
}

- (HyCyclePageView *)cyclePageView {
    if (!_cyclePageView){
         __weak typeof(self) _self = self;
        _cyclePageView = [[HyCyclePageView alloc] initWithFrame:_scrollView.bounds];
        [[[[[[_cyclePageView.configure totalIndexs:^NSInteger(HyCyclePageView * _Nonnull cycleView) {
            __strong typeof(_self) self = _self;
            return self.titleArray.count;
        }] viewProviderAtIndex:^id<HyCyclePageViewProviderProtocol> _Nonnull(HyCyclePageView * _Nonnull cycleView, NSInteger index) {
            __strong typeof(_self) self = _self;
            CyclePageViewDemoTestController *vc = CyclePageViewDemoTestController.new;
            vc.scrollViewDidEndDragging = self.scrollViewDidEndDragging;
            return vc;
        }] scrollProgress:^(HyCyclePageView * _Nonnull cycleView, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
            __strong typeof(_self) self = _self;
            [self.segmentView clickItemFromIndex:fromIndex
                                         toIndex:toIndex
                                        progress:progress];
        }] headerView:self.headerView] hoverView:self.hoverView] loadStyle:HyCycleViewLoadStyleDidAppear];
        
        !self.configPageView ?: self.configPageView(_cyclePageView.configure);
    }
    return _cyclePageView;
}

- (HySegmentView *)segmentView {
    if (!_segmentView){
        
        __weak typeof(self) _self = self;
        _segmentView =
        [HySegmentView segmentViewWithFrame:CGRectMake(0, 0, self.view.width, 40)
                             configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
            
            __strong typeof(_self) self = _self;
            configure
            .numberOfItems(self.titleArray.count)
            .itemMargin(25)
            .viewForItemAtIndex(^UIView *(UIView *currentView,
                                          NSInteger currentIndex,
                                          CGFloat progress,
                                          HySegmentViewItemPosition position,
                                          NSArray<UIView *> *animationViews){
                __strong typeof(_self) self = _self;
                UILabel *label = (UILabel *)currentView;
                if (!label) {
                    label = [UILabel new];
                    label.text = self.titleArray[currentIndex];
                    label.textAlignment = NSTextAlignmentCenter;
                    [label sizeToFit];
                }
                if (progress == 0 || progress == 1) {
                    label.textColor =  progress == 0 ? UIColor.darkTextColor : UIColor.redColor;
                }
                return label;
            })
             .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                 
                 NSArray<UIView *> *array = currentAnimations;
                 if (!array.count) {
                     UIView *line = [UIView new];
                     line.backgroundColor = UIColor.redColor;
                     line.layer.cornerRadius = 1.5;
                     line.heightValue(3).bottomValue(40);
                     array = @[line];
                 }
                 
                 CGFloat margin = ABS(toCell.centerX - fromCell.centerX);
                 CGFloat currentProgress = progress <= 0.5 ? progress : (1 - progress);
                 CGFloat width = 15;
                 array.firstObject.widthValue(width + margin * currentProgress * 2);
                 
                 if (fromIndex < toIndex) {
                     if (progress <= 0.5) {
                         array.firstObject.leftValue(fromCell.centerX - width / 2);
                     } else {
                         array.firstObject.rightValue(toCell.centerX + width / 2);
                     }
                 } else {
                     if (progress <= 0.5) {
                         array.firstObject.rightValue(fromCell.centerX + width / 2);
                     } else {
                         array.firstObject.leftValue(toCell.centerX - width / 2);
                     };
                 }
                 
                 return array;
             })
            .clickItemAtIndex(^BOOL(NSInteger currentIndex, BOOL isRepeat){
                __strong typeof(_self) self = _self;
                if (!isRepeat) {
                    [self.cyclePageView scrollToIndex:currentIndex animated:YES];
                }
                return NO;
            });
            !self.configSegmentView ?: self.configSegmentView(configure);
        }];
    }
    return _segmentView;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
