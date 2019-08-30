//
//  CyclePageViewSpecialOneDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewSpecialOneDemoController.h"


@implementation CyclePageViewSpecialOneDemoController

- (NSArray<NSString *> *)titleArray {
    return @[@"附近动态",@"附近的人",@"附近直播"];
}

- (UIView *)headerView {
    return nil;
}

- (void (^)(HySegmentViewConfigure * _Nonnull))configSegmentView {
    __weak typeof(self) weakSelf = self;
    return ^(HySegmentViewConfigure * _Nonnull configure) {
        configure
        .keepingMarginAndInset(YES)
        .itemMargin(15)
        .viewForItemAtIndex(^UIView *(UIView *currentView,
                                      NSInteger currentIndex,
                                      CGFloat progress,
                                      HySegmentViewItemPosition position,
                                      NSArray<UIView *> *animationViews) {
            
            UILabel *label = (UILabel *)currentView;
            if (!label) {
                label = [UILabel new];
                label.text = weakSelf.titleArray[currentIndex];
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = UIColor.darkTextColor;
                label.font = [UIFont boldSystemFontOfSize:15];
                [label sizeToFit];
            }
            label.transform =  CGAffineTransformMakeScale(1 + .45 * progress, 1 + .45 * progress);
            return label;
        });
    };
}

@end
