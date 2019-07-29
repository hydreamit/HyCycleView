//
//  HySegmentViewDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/23.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HySegmentViewDemoController.h"
#import "HyDrawTextColorLabel.h"
#import "HySegmentView.h"
#import "HyCycleView.h"


@interface HySegmentViewDemoController ()
@property (nonatomic,strong) UIScrollView *scrollView;
@end


@implementation HySegmentViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    [self.view addSubview:self.scrollView];
    
    [self lineOneWithBlock:^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {

        NSArray<UIView *> *array = currentAnimations;
        if (!array.count) {
            UIView *line = [UIView new];
            line.backgroundColor = UIColor.redColor;
            line.sizeValue(40, 3).bottomValue(40);
            array = @[line];
        }
        array.firstObject.centerXValue((1 - progress) * fromCell.centerX + progress * toCell.centerX);
        return array;
    }];
    
    [self lineOneWithBlock:^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
        
        NSArray<UIView *> *array = currentAnimations;
        if (!array.count) {
            UIView *line = [UIView new];
            line.backgroundColor = UIColor.redColor;
            line.sizeValue(40, 3).bottomValue(40);
            array = @[line];
        }
        array.firstObject.centerXValue((1 - progress) * fromCell.centerX + progress * toCell.centerX);
        return array;
    }];
    
    [self lineOneWithBlock:^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
        
        NSArray<UIView *> *array = currentAnimations;
        if (!array.count) {
            UIView *line = [UIView new];
            line.backgroundColor = UIColor.redColor;
            line.heightValue(3).bottomValue(40);
            array = @[line];
        }

        CGFloat margin = toCell.centerX - fromCell.centerX;
        CGFloat widthMargin = (toCell.width - fromCell.width) * 1.2;
        array.firstObject
        .widthValue(fromCell.width * 1.2 + widthMargin * progress)
        .centerXValue(fromCell.centerX + margin * progress);
        
        return array;
    }];
    
    [self lineOneWithBlock:^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
        
        NSArray<UIView *> *array = currentAnimations;
        if (!array.count) {
            UIView *line = [UIView new];
            line.backgroundColor = UIColor.redColor;
            line.heightValue(3).bottomValue(40);
            array = @[line];
        }
        
        CGFloat margin = ABS(toCell.centerX - fromCell.centerX);
        CGFloat currentProgress = progress <= 0.5 ? progress : (1 - progress);
        CGFloat width = 20;
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
    }];
    
    [self lineOneWithBlock:^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
        
        NSArray<UIView *> *array = currentAnimations;
        if (!array.count) {
            UIView *line = [UIView new];
            line.backgroundColor = UIColor.redColor;
            line.heightValue(3).bottomValue(40);
            array = @[line];
        }
        
        CGFloat width = progress <= 0.5 ? fromCell.width * 1.2 : toCell.width  * 1.2;
        CGFloat currentProgress = progress <= 0.5 ? progress : (1 - progress);
        
       if (fromIndex < toIndex) {
           if (progress <= 0.5) {

               CGFloat margin = ABS(toCell.right - fromCell.right);
               array.firstObject
               .widthValue(width + margin * currentProgress * 2)
               .leftValue(fromCell.centerX - width / 2);

           } else {
               CGFloat margin = ABS(toCell.left - fromCell.left);
               array.firstObject
               .widthValue(width + margin * currentProgress * 2)
               .rightValue(toCell.centerX + width / 2);
           }
       } else {

           if (progress <= 0.5) {
               CGFloat margin = ABS(toCell.left - fromCell.left);
               array.firstObject
               .widthValue(width + margin * currentProgress * 2)
               .rightValue(fromCell.centerX + width / 2);
           } else {
               CGFloat margin = ABS(toCell.right - fromCell.right);
               array.firstObject
               .widthValue(width + margin * currentProgress * 2)
               .leftValue(toCell.centerX - width / 2);
           };
       }
        
        return array;
    }];
    
    
    [self lineOneWithBlock:^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress) {
        
        UIView *line = [UIView new];
        line.backgroundColor = UIColor.redColor;
        
        UIView *itemView = progress <= 0.5 ? fromCell : toCell;
        CGFloat width = itemView.width;
        CGFloat margin = ABS(toCell.centerX - fromCell.centerX);
        CGFloat currentProgress = progress <= 0.5 ? progress : (1 - progress);

        line
        .heightValue(3)
        .bottomValue(40)
        .widthValue(width + (margin - width) * currentProgress * 2);
        
       if (fromIndex < toIndex) {
           if (progress <= 0.5) {
               line.leftValue(fromCell.centerX - width / 2 + (width * currentProgress));
           } else {
               line.rightValue(toCell.right - width * currentProgress);
           }
       } else {
           if (progress <= 0.5) {
               line.rightValue(fromCell.right - width * currentProgress);
           } else {
               line.leftValue(toCell.centerX - width / 2 + (width * currentProgress));
           };
       }
        
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.grayColor;
        view.heightValue(30).widthValue(line.width + 20).centerXIsEqualTo(line).centerYValue(fromCell.height / 2);
        
        if (toIndex == 0 || toIndex == 2 || fromIndex == 0 || fromIndex == 2) {
            CGFloat ssprogress = 1 - progress;
            if (toIndex == 0 || toIndex == 2) {
                ssprogress = progress;
            }
            view.layer.cornerRadius = view.height / 2 * (1 - ssprogress);
            view.heightValue(30 + 10 * ssprogress).centerYValue(fromCell.height / 2);
        } else {
            view.layer.cornerRadius = view.height / 2;
        }
        
        return @[line, view];
    }];
    
    self.scrollView.contentSize = CGSizeMake(0, self.scrollView.subviews.lastObject.bottom + 10);
}

- (void)lineOneWithBlock:(NSArray<UIView *> *(^)(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress))block {
    
    NSArray *colorArray = @[UIColor.magentaColor, UIColor.orangeColor, UIColor.purpleColor, UIColor.yellowColor, UIColor.blueColor, UIColor.greenColor, UIColor.cyanColor, UIColor.brownColor, UIColor.purpleColor];
    
    NSArray *titleArray = @[@"NBA", @"国际足球", @"中国篮球", @"跑步",@"欧洲杯", @"欧冠" ,@"英超", @"西甲", @"意甲"];
    
    UIView *testView = [[UIView alloc] init];
    testView.frame = CGRectMake(0, self.scrollView.subviews.lastObject.bottom + 10, self.scrollView.width, 90);
    testView.tag = self.scrollView.subviews.count;
    
    HyCycleView *cycleView =
    [HyCycleView cycleViewWithFrame:CGRectMake(0, 40, testView.width, 50)
                     configureBlock:^(HyCycleViewConfigure *configure) {
                         configure
                         .totalPage(9)
                         .cycleClasses(@[UIView.class])
                         .viewWillAppear(^(HyCycleView *cycleView,
                                           UIView *view,
                                           NSInteger currentPage,
                                           BOOL isfirtLoad){
                             view.backgroundColor = colorArray[currentPage];
                         });
                     }];
    
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(testView) weakTestView = testView;
    __weak typeof(cycleView) weakCycleView = cycleView;
    
    HySegmentView *segmentView =
    [HySegmentView segmentViewWithFrame:CGRectMake(0, 0, testView.width, 40) configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
        
        configure
        .numberOfItems(9)
        .itemMargin(25)
        .viewForItemAtIndex(^UIView *(UIView *currentView,
                                      NSInteger currentIndex,
                                      CGFloat progress,
                                      HySegmentViewItemPosition position,
                                      NSArray<UIView *> *animationViews){
            
            UIView *view = currentView;
            if (!view) {
                
                if (currentIndex == 2) {
                    view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"one"]].sizeValue(25, 25);
                } else {
                    
                    HyDrawTextColorLabel *label = [[HyDrawTextColorLabel alloc] init];
                    label.text = titleArray[currentIndex];
                    label.textAlignment = NSTextAlignmentCenter;
                    [label sizeToFit];
                    
                    if (currentIndex == 0) {
                        
                        view = [[UIView alloc] init].sizeValue(30, 30);
                        
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"one"]];
                        imageView.sizeValue(15, 15).centerXValue(15);
                        [view addSubview:imageView];
                        
                        
                        label.font = [UIFont systemFontOfSize:12];
                        [label sizeToFit];
                        label.bottomValue(30).centerXIsEqualTo(imageView);
                        [view addSubview:label];
                        
                    } else {
                        
                        view = label;
                    }
                }
            }
            
            if (currentIndex == 0 || currentIndex == 2) {
                UIImageView *imageView = (UIImageView *)view;
                if (currentIndex == 0) {
                    imageView = view.subviews.firstObject;
                }
                if (progress == 0 || progress == 1) {
                    imageView.image = progress == 0 ? [UIImage imageNamed:@"one"] : [UIImage imageNamed:@"two"];
                }
            }
            
            if (currentIndex != 2) {
                
                HyDrawTextColorLabel *label = (HyDrawTextColorLabel *)view;
                if (currentIndex == 0) {
                    label = view.subviews.lastObject;
                }
                
                if (weakTestView.tag < 4 && weakTestView.tag != 1) {
                    
                    NSArray *selectedRGB = [weakSelf getRGBComponentsForColor:colorArray[currentIndex]];
                    NSArray *normalRGB = [weakSelf getRGBComponentsForColor:UIColor.darkGrayColor];
                    
                    NSInteger colorR = [normalRGB.firstObject integerValue] + ([selectedRGB.firstObject integerValue] - [normalRGB.firstObject integerValue]) * progress;
                    
                    NSInteger colorG = [normalRGB[1] integerValue] + ([selectedRGB[1] integerValue] - [normalRGB[1] integerValue]) * progress;
                    
                    NSInteger colorB = [normalRGB.lastObject integerValue] + ([selectedRGB.lastObject integerValue] - [normalRGB.lastObject integerValue]) * progress;
                    
                    UIColor *currentColor = [UIColor colorWithRed:colorR / 255.0 green:colorG / 255.0 blue:colorB / 255.0 alpha:1];
                    
                    label.textColor = currentColor;
                    
                } else {
                    
                    if (progress == 0) {
                        
                        label.textColor = UIColor.darkGrayColor;
                        [label drawTextColor:UIColor.darkGrayColor progress:0];
                        
                    } else if (progress == 1) {
                        
                        label.textColor = colorArray[currentIndex];
                        [label drawTextColor:colorArray[currentIndex] progress:0];
                        
                    } else {
                        if ([weakSelf checkColor:label.textColor otherColor:UIColor.darkGrayColor]) {
                            
                            if (position == HySegmentViewItemPositionLeft) {
                                [label drawTextColor:colorArray[currentIndex] progress:-progress];
                            }
                            if (position == HySegmentViewItemPositionRight) {
                                [label drawTextColor:colorArray[currentIndex] progress:progress];
                            }
                            
                        } else {
                            
                            if (position == HySegmentViewItemPositionLeft) {
                                [label drawTextColor:UIColor.darkGrayColor progress:-(1-progress)];
                            }
                            if (position == HySegmentViewItemPositionRight) {
                                [label drawTextColor:UIColor.darkGrayColor progress:1 - progress];
                            }
                        }
                    }
                }
            }
                        
            if (weakTestView.tag != 5) {
                view.transform =  CGAffineTransformMakeScale(1 + 0.2 * progress, 1 + 0.2 * progress);
            }
            return view;
        })
        .clickItemAtIndex(^(NSInteger currentIndex, BOOL isRepeat){
            if (!isRepeat) {
                [weakCycleView scrollToPage:currentIndex animated:YES];
            }
        })
        .animationViews(block);
    }];
    
        __weak typeof(segmentView) weakSegmentView = segmentView;

    cycleView.configure.scrollProgress(^(HyCycleView *cycleView,
                                          NSInteger fromPage,
                                          NSInteger toPage,
                                          CGFloat progress) {

        [weakSegmentView clickItemFromIndex:fromPage
                                    toIndex:toPage
                                   progress:progress];
    });
    
    [testView addSubview:segmentView];
    [testView addSubview:cycleView];
    
    [self.scrollView addSubview:testView];
}

- (UIScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (NSArray<NSNumber *> *)getRGBComponentsForColor:(UIColor *)color {
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 1);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    NSMutableArray *array = @[].mutableCopy;
    for (int component = 0; component < 3; component++) {
        
        [array addObject:@(resultingPixel[component])];
        
    }
    return array;
}

- (BOOL)checkColor:(UIColor *)color otherColor:(UIColor *)otherColor {
    
    NSArray *colorRGBArray = [self getRGBComponentsForColor:color];
    NSArray *otherColorRGBArray = [self getRGBComponentsForColor:otherColor];
    
    __block BOOL isSame = YES;
    [colorRGBArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (otherColorRGBArray[idx] != obj) {
            isSame = NO;
            *stop = YES;
        }
    }];
    return isSame;
}

@end
