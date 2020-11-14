//
//  CycleCustomViewDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CycleCustomViewDemoController.h"
#import "HyCustomView.h"
#import "HyCycleView.h"
#import "HySegmentView.h"
#import "UIView+HyFrame.h"


@interface CycleCustomViewDemoController ()<HyCycleViewProviderProtocol>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSArray<NSDictionary *> *dataArray;
@end


@implementation CycleCustomViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.scrollView];
    
    [self createCycleCustomView];
    [self createMutiCycleCustomView];
    [self createNoticeCycleView];
    
    self.scrollView.contentSize = CGSizeMake(0, self.scrollView.subviews.lastObject.bottom + 20);
}

- (void)configCycleView:(HyCycleViewProvider<HyCycleView *> *)provider index:(NSInteger)index {
    [provider view:^UIView * _Nonnull(HyCycleView * _Nonnull cycleView) {
        if (cycleView.tag == 1) {
           return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(HyCustomView.class) owner:nil options:nil] lastObject];
        } else if (cycleView.tag == 2) {
           if (index == 1 || index == 3) {
               UIImageView *imageView = [[UIImageView alloc] init];
               imageView.contentMode = UIViewContentModeScaleAspectFill;
               imageView.clipsToBounds = YES;
               return imageView;
           }
           return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(HyCustomView.class) owner:nil options:nil] lastObject];
        } else {
          return UILabel.new;
        }
    }];
}


- (void)createCycleCustomView {
    
    NSArray *dataArray =
    @[
      @{ @"title" : @"春晓",
         @"subTitle" : @"春眠不觉晓",
         @"content" : @[@"one", @"two", @"three"]
         },
      @{ @"title" : @"春晓",
         @"subTitle" : @"处处闻啼鸟",
         @"content" : @[@"four", @"one", @"two"]
         },
      @{ @"title" : @"春晓",
         @"subTitle" : @"夜来风雨声",
         @"content" : @[@"three", @"two"]
         },
      @{ @"title" : @"春晓",
         @"subTitle" : @"花落知多少",
         @"content" : @[@"one"]
         },
      ];
    
    HySegmentView *segment = [self segment];
    segment.backgroundColor = UIColor.clearColor;
    
    __weak typeof(self) _self = self;
    HyCycleView *cycleView = [[HyCycleView alloc] initWithFrame:CGRectMake(30, 10, self.scrollView.width - 60, 180)];
    cycleView.tag = 1;
    [[[[[[cycleView.configure totalIndexs:^NSInteger(HyCycleView * _Nonnull cycleView) {
        return dataArray.count;
    }] roundingIndexChange:^(HyCycleView * _Nonnull cycleView, NSInteger indexs, NSInteger roundingIndex) {
        if (!segment.superview) {
            segment.leftValue(cycleView.width - segment.width);
            segment.bottomValue(cycleView.height - 5);
            [cycleView addSubview:segment];
        }
        [segment clickItemAtIndex:roundingIndex];
    }] viewWillAppearAtIndex:^(HyCycleView * _Nonnull cycleView, HyCustomView *view, NSInteger index, BOOL isFirstLoad) {
        if (isFirstLoad) {
            [view setDict:dataArray[index]];
        }
    }] viewProviderAtIndex:^id<HyCycleViewProviderProtocol> _Nonnull(HyCycleView * _Nonnull cycleView, NSInteger index) {
        __strong typeof(_self) self = _self;
        return self;
    }] isAutoCycle:YES] isCycle:YES];
    [self.scrollView addSubview:cycleView];
    [cycleView reloadData];
}

- (void)createMutiCycleCustomView {
    
    NSArray *dataArray =
    @[
      @{ @"title" : @"春晓",
         @"subTitle" : @"春眠不觉晓",
         @"content" : @[@"one", @"two", @"three"]
         },
      
      @{ @"image" : @"two"},
      
      @{ @"title" : @"春晓",
         @"subTitle" : @"夜来风雨声",
         @"content" : @[@"three", @"two"]
         },
      
      @{ @"image" : @"one"},
      ];

    
    HySegmentView *segment = [self segment];
    segment.backgroundColor = UIColor.clearColor;
    
    HyCycleView *cycleView = [[HyCycleView alloc] initWithFrame:CGRectMake(30, self.scrollView.subviews.lastObject.bottom + 20, self.scrollView.width - 60, 180)];
    cycleView.tag =2;
    __weak typeof(self) _self = self;
    [[[[[[[cycleView.configure totalIndexs:^NSInteger(HyCycleView * _Nonnull cycleView) {
        return dataArray.count;
    }] direction:HyCycleViewDirectionTop] viewProviderAtIndex:^id<HyCycleViewProviderProtocol> _Nonnull(HyCycleView * _Nonnull cycleView, NSInteger index) {
        __strong typeof(_self) self = _self;
        return self;
    }] viewWillAppearAtIndex:^(HyCycleView * _Nonnull cycleView, UIView *contentView, NSInteger index, BOOL isFirstLoad) {
        if (isFirstLoad) {
            if ([contentView isKindOfClass:HyCustomView.class]) {
                [((HyCustomView *)contentView) setDict:dataArray[index]];
            } else {
                ((UIImageView *)contentView).contentMode = UIViewContentModeScaleAspectFill;
                ((UIImageView *)contentView).image = [UIImage imageNamed:dataArray[index][@"image"]];
            }
        }
    }] roundingIndexChange:^(HyCycleView * _Nonnull cycleView, NSInteger indexs, NSInteger roundingIndex) {
        if (!segment.superview) {
            segment.leftValue(cycleView.width - segment.width);
            segment.bottomValue(cycleView.height - 5);
            [cycleView addSubview:segment];
        }
        [segment clickItemAtIndex:indexs - 1 - roundingIndex];
    }] isCycle:YES] isAutoCycle:YES];
    [self.scrollView addSubview:cycleView];
    [cycleView reloadData];
}

- (void)createNoticeCycleView {
    
    NSArray *noticeArray = @[@"☪ 春眠不觉晓",
                             @"☪ 春眠不觉晓, 处处闻啼鸟",
                             @"☪ 春眠不觉晓, 处处闻啼鸟, 夜来风雨声",
                             @"☪ 春眠不觉晓, 处处闻啼鸟, 夜来风雨声, 花落知多少"];
    
    HyCycleView *cycleView = [[HyCycleView alloc] initWithFrame:CGRectMake(30, self.scrollView.subviews.lastObject.bottom + 20, self.scrollView.width - 60, 45)];
    cycleView.tag = 3;
    __weak typeof(self) _self = self;
    [[[[[[cycleView.configure totalIndexs:^NSInteger(HyCycleView * _Nonnull cycleView) {
        return noticeArray.count;
    }] direction:HyCycleViewDirectionBottom] viewProviderAtIndex:^id<HyCycleViewProviderProtocol> _Nonnull(HyCycleView * _Nonnull cycleView, NSInteger index) {
        __strong typeof(_self) self = _self;
        return self;
    }] viewWillAppearAtIndex:^(HyCycleView * _Nonnull cycleView, UILabel *label, NSInteger index, BOOL isFirstLoad) {
        if (isFirstLoad) {
            label.textColor = UIColor.purpleColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:13];
        }
        label.text = noticeArray[index];
    }] isCycle:YES] isAutoCycle:YES];
    
    cycleView.layer.borderColor = UIColor.purpleColor.CGColor;
    cycleView.layer.borderWidth = .5;
    cycleView.layer.cornerRadius = 5.0;
    cycleView.layer.masksToBounds = YES;
    [self.scrollView addSubview:cycleView];
    [cycleView reloadData];
}

- (CGRect)cycleViewFrame {
    
    CGFloat y = self.scrollView.subviews.count ? self.scrollView.subviews.lastObject.bottom : 0;
    return CGRectMake(30, y + 10, self.scrollView.width - 60, 200);
}

- (UIScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (HySegmentView *)segment {
    
    return
    [HySegmentView segmentViewWithFrame:CGRectMake(0, 0, 14 * 4 + 18, 7)
                         configureBlock:^(HySegmentViewConfigure *configure) {
        
        configure
        .keepingMarginAndInset(YES)
        .itemMargin(7)
        .numberOfItems(4)
        .viewForItemAtIndex(^UIView *(UIView *currentView,
                                      NSInteger pageNumber,
                                      CGFloat progress,
                                      HySegmentViewItemPosition positon,
                                      NSArray<UIView *> *animationViews) {
            
            UIView *view = currentView;
            if (!view) {
                view = [UIView new];
                view.layer.masksToBounds = YES;
                view.backgroundColor = UIColor.whiteColor;
                view.layer.cornerRadius = 3.5;
            }
            
            if (progress == 0) {
                view.alpha = .5;
                view.sizeValue(7, 7);
            }
            
            if (progress == 1) {
                view.alpha = .85;
                view.sizeValue(16, 7);
            }
            return view;
            
        }).clickItemAtIndex(^BOOL(NSInteger page,
                                  BOOL isRepeat){
            return NO;
        });
    }];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
