//
//  CyclePageViewSpecialTwoDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewSpecialTwoDemoController.h"


@interface CyclePageViewSpecialTwoDemoController ()
@property (nonatomic,strong) HySegmentView *segmentView;
@end


@implementation CyclePageViewSpecialTwoDemoController
@dynamic segmentView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentView.sizeValue(250, 30);
    self.segmentView.layer.cornerRadius = self.segmentView.height / 2;
    self.segmentView.backgroundColor = UIColor.whiteColor;
    self.segmentView.layer.borderColor = UIColor.orangeColor.CGColor;
    self.segmentView.layer.borderWidth = 1.0;
    self.segmentView.layer.masksToBounds = YES;
    self.navigationItem.titleView = self.segmentView;;
}

- (UIView *)hoverView {
    return nil;
}

- (UIView *)headerView {
    return nil;
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure) {
        configure.totalPage(3);
    };
}

- (void (^)(HySegmentViewConfigure * _Nonnull))configSegmentView {
    return ^(HySegmentViewConfigure * _Nonnull configure) {
        
        configure
        .itemMargin(0)
        .numberOfItems(3)
        .insetAndMarginRatio(.5)
        .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
            
            NSArray<UIView *> *array = currentAnimations;
            if (!array.count) {
                UIView *line = [UIView new];
                line.backgroundColor = UIColor.orangeColor;
                line.height = fromCell.height;
                line.layer.cornerRadius = 2.0;
                line.layer.cornerRadius = line.height / 2;
                array = @[line];
            }
            
            CGFloat margin = toCell.centerX - fromCell.centerX;
            CGFloat widthMargin = (toCell.width - fromCell.width);
            array.firstObject
            .widthValue(fromCell.width + widthMargin * progress + configure.getItemMargin)
            .centerXValue(fromCell.centerX + margin * progress);
      
            return array;
        });
    };
}

@end
