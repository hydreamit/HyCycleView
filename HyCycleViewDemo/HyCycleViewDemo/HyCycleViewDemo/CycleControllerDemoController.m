//
//  CycleControllerDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//
#import "CycleControllerDemoTestController.h"
#import "CycleControllerDemoController.h"
#import "HySegmentView.h"
#import "HyCycleView.h"


@interface CycleControllerDemoController ()
@property (nonatomic,strong) HyCycleView *cycleView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) HySegmentView *segmentView;
@end


@implementation CycleControllerDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) _self = self;
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.scrollView];

    NSArray *titleArray = @[@"体育", @"资讯快报", @"社区", @"个人中心"];
    
    self.segmentView =
    [HySegmentView segmentViewWithFrame:CGRectZero
                         configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
                             
                             configure
                             .numberOfItems(4)
        .startIndex(2)
                             .viewForItemAtIndex(^UIView *(UIView *currentView,
                                                           NSInteger currentIndex,
                                                           CGFloat progress,
                                                           HySegmentViewItemPosition position,
                                                           NSArray<UIView *> *animationViews) {
                                 
                                 UILabel *label = (UILabel *)currentView;
                                 if (!label) {
                                     label = [UILabel new];
                                     label.text = titleArray[currentIndex];
                                     label.textAlignment = NSTextAlignmentCenter;
                                     [label sizeToFit];
                                 }
                                 if (progress == 0 || progress == 1) {
                                     label.textColor =  progress == 0 ? UIColor.darkTextColor : UIColor.orangeColor;
                                 }
                                 return label;
                             })
                             .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                                 NSArray<UIView *> *array = currentAnimations;
                                 if (!array.count) {
                                     UIView *line = [UIView new];
                                     line.backgroundColor = UIColor.orangeColor;
                                     line.layer.cornerRadius = 2;
                                     line.widthValue(50).heightValue(5);
                                     array = @[line];
                                 }
                                 
                                 CGFloat margin = toCell.centerX - fromCell.centerX;
                                 CGFloat widthMargin = (toCell.width - fromCell.width);
                                 array.firstObject
                                 .widthValue(fromCell.width + widthMargin * progress)
                                 .centerXValue(fromCell.centerX + margin * progress);
                                 
                                 return array;
                             })
                             .clickItemAtIndex(^BOOL(NSInteger currentIndex, BOOL isRepeat){
                                 __strong typeof(_self) self = _self;
                                 if (!isRepeat) {
                                     [self.cycleView scrollToIndex:currentIndex animated:YES];
                                 }
                                 return NO;
                             });
    }];
    [self.scrollView addSubview:self.segmentView];
    
    
    self.cycleView = [[HyCycleView alloc] initWithFrame:CGRectMake(30, 10, self.scrollView.width - 60, 180)];
    [[[self.cycleView.configure totalIndexs:^NSInteger(HyCycleView * _Nonnull cycleView) {
        return 4;
    }] viewProviderAtIndex:^id<HyCycleViewProviderProtocol> _Nonnull(HyCycleView * _Nonnull cycleView, NSInteger index) {
        return [CycleControllerDemoTestController new];
    }] scrollProgress:^(HyCycleView * _Nonnull cycleView, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
        __strong typeof(_self) self = _self;
        [self.segmentView clickItemFromIndex:fromIndex
                                         toIndex:toIndex
                                        progress:progress];
    }];
    
    [self.scrollView addSubview:self.cycleView];
    [self.cycleView reloadData];
    
    [self.cycleView.configure loadStyle:HyCycleViewLoadStyleDidAppear];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat segmentH = self.scrollView.adjustedContentInset.bottom + 40;
    
    self.cycleView.rectValue(0 , 0, self.scrollView.width, self.scrollView.height - self.scrollView.adjustedContentInset.top - segmentH);
    
    self.segmentView
    .topValue(self.cycleView.bottom)
    .widthIsEqualTo(self.cycleView)
    .heightValue(segmentH);
}

- (UIScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
