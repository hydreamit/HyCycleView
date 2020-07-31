//
//  CyclePageViewSpecialTwoDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewSpecialTwoDemoController.h"
#import "HyDrawTextColorLabel.h"


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

- (NSArray<NSString *> *)titleArray {
    return @[@"NBA", @"国际足球", @"中国篮球"];
}

- (UIView *)hoverView {
    return nil;
}

- (UIView *)headerView {
    return nil;
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    return ^(HyCyclePageViewConfigure * _Nonnull configure) {
        [configure totalIndexs:^NSInteger(HyCyclePageView * _Nonnull cycleView) {
            return 3;
        }];
    };
}

- (void (^)(HySegmentViewConfigure * _Nonnull))configSegmentView {
    __weak typeof(self) _self = self;
    return ^(HySegmentViewConfigure * _Nonnull configure) {
        
        configure
        .itemMargin(MAXFLOAT)
        .numberOfItems(3)
        .insetAndMarginRatio(.5)
        .viewForItemAtIndex(^UIView *(UIView *currentView,
                                      NSInteger currentIndex,
                                      CGFloat progress,
                                      HySegmentViewItemPosition position,
                                      NSArray<UIView *> *animationViews){

                        __strong typeof(_self) self = _self;
                        HyDrawTextColorLabel *label = (HyDrawTextColorLabel *)currentView;
                       if (!label) {
                           label = [HyDrawTextColorLabel new];
                           label.tag = 99;
                           label.text = self.titleArray[currentIndex];
                           label.textAlignment = NSTextAlignmentCenter;
                           [label sizeToFit];
                           label.width += 8;
                           label.textColor = UIColor.darkTextColor;
                       }
            
                    return label;
        })
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
            
            UICollectionView *collectionView = (UICollectionView *)fromCell.superview;
            if ([collectionView isKindOfClass:UICollectionView.class]) {
                
                UIView *animationView = array.firstObject;
                
                NSArray<UICollectionViewCell *> *cells = collectionView.visibleCells;
                [cells enumerateObjectsUsingBlock:^(UICollectionViewCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    HyDrawTextColorLabel *label = [cell.contentView viewWithTag:99];
                    
                    CGFloat leftMargin = animationView.left - cell.left;
                    leftMargin = leftMargin >= 0 ? leftMargin : 0;
                    
                    CGFloat rightMargin = cell.right - animationView.right;
                    rightMargin = rightMargin < 0 ? cell.width : (cell.width - rightMargin);
                    
                    CGFloat width = rightMargin - leftMargin;
                    if (width > 0) {
                       CGRect rect = CGRectMake(leftMargin, 0, width, 26);
                       [label drawTextColor:UIColor.whiteColor rect:rect];
                    }
                }];
            }
            return array;
        });
    };
}

@end
