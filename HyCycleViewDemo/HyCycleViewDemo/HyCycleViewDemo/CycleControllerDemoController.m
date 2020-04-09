//
//  CycleControllerDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

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
    
    __weak typeof(self) weakSelf = self;
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.scrollView];
    
    
    NSArray *titleArray = @[@"体育", @"资讯快报", @"社区", @"个人中心"];
    
    self.segmentView =
    [HySegmentView segmentViewWithFrame:CGRectZero
                         configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
                             
                             configure
                             .numberOfItems(4)
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
                                 
                                 if (!isRepeat) {
                                     [weakSelf.cycleView scrollToPage:currentIndex animated:YES];
                                 }
                                 return NO;
                             });
    }];
    
    UIViewController *vc1 = [[UIViewController alloc] init];
    vc1.view.backgroundColor = UIColor.purpleColor;
    UIViewController *vc2 = [[UIViewController alloc] init];
    vc2.view.backgroundColor = UIColor.redColor;
    UIViewController *vc3 = [[UIViewController alloc] init];
    vc3.view.backgroundColor = UIColor.greenColor;
    UIViewController *vc4 = [[UIViewController alloc] init];
    vc4.view.backgroundColor = UIColor.blueColor;
    
    self.cycleView =
    [HyCycleView cycleViewWithFrame:self.scrollView.bounds
                     configureBlock:^(HyCycleViewConfigure *configure) {
                         
                         configure
                         .scrollStyle(HyCycleViewScrollStatic)
                         .cycleInstances(@[vc1, vc2, vc3,vc4])
                         .scrollProgress(^(HyCycleView *cycleView,
                                             NSInteger fromPage,
                                             NSInteger toPage,
                                             CGFloat progress) {
                             
                             [weakSelf.segmentView clickItemFromIndex:fromPage
                                                              toIndex:toPage
                                                             progress:progress];
                         });
                     }];
    
    [self.scrollView addSubview:self.cycleView];
    [self.scrollView addSubview:self.segmentView];
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
