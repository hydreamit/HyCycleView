//
//  CycleImageViewDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CycleImageViewDemoController.h"
#import "HyCycleView.h"
#import "UIView+HyFrame.h"


@interface CycleImageViewDemoController ()<HyCycleViewProviderProtocol>
@property (nonatomic,strong) NSArray<NSString *> *imageNameArray;
@property (nonatomic,strong) UIScrollView *scrollView;
@end


@implementation CycleImageViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.imageNameArray = @[@"one",@"two",@"three",@"four"];
    [self.view addSubview:self.scrollView];
    
    [self createCycleViewOne];
    [self createCycleViewTwo];
    [self createCycleViewThree];
    [self createCycleViewFour];

    self.scrollView.contentSize = CGSizeMake(0, self.scrollView.subviews.lastObject.bottom + 20);
}

- (void)configCycleView:(HyCycleViewProvider<HyCycleView *> *)provider index:(NSInteger)index {
    [provider view:^UIView * _Nonnull(HyCycleView * _Nonnull cycleView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        return imageView;
    }];
}

- (void)createCycleViewOne {
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    
    HyCycleView *cycleView = [self addCycleViewWithDirection:HyCycleViewDirectionLeft];
    [cycleView.configure roundingIndexChange:^(HyCycleView * _Nonnull cycleView, NSInteger indexs, NSInteger roundingIndex) {
                
        if (!pageControl.superview && indexs > 1) {
            CGFloat pageW = 15 * indexs;
            CGFloat pageH = 20;
            CGFloat pageX = (cycleView.frame.size.width - pageW) / 2;
            CGFloat pageY = cycleView.frame.size.height - pageH;
            pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
            [cycleView addSubview:pageControl];
            pageControl.numberOfPages = indexs;
        }
        pageControl.currentPage = roundingIndex;
    }];
    [cycleView reloadData];
}


- (void)createCycleViewTwo {
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    
    HyCycleView *cycleView = [self addCycleViewWithDirection:HyCycleViewDirectionRight];
    [cycleView.configure roundingIndexChange:^(HyCycleView * _Nonnull cycleView, NSInteger indexs, NSInteger roundingIndex) {
         if (!pageControl.superview && indexs > 1) {
             CGFloat pageW = 15 * indexs;
             CGFloat pageH = 20;
             CGFloat pageX = cycleView.frame.size.width - pageW - 5;
             CGFloat pageY = cycleView.frame.size.height - pageH;
             pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
             [cycleView addSubview:pageControl];
             pageControl.numberOfPages = indexs;
         }
         pageControl.currentPage = indexs - roundingIndex - 1;
    }];
    [cycleView reloadData];
}

- (void)createCycleViewThree {
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);

    HyCycleView *cycleView = [self addCycleViewWithDirection:HyCycleViewDirectionTop];
    [cycleView.configure roundingIndexChange:^(HyCycleView * _Nonnull cycleView, NSInteger indexs, NSInteger roundingIndex) {
         if (!pageControl.superview && indexs > 1) {
               CGFloat pageW = 15 * indexs;
               CGFloat pageH = 20;
               CGFloat pageX = cycleView.frame.size.width - pageW / 2 - 10;
               CGFloat pageY = cycleView.frame.size.height - pageW / 2 - 15;
               pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
               [cycleView addSubview:pageControl];
               pageControl.numberOfPages = indexs;
           }
           pageControl.currentPage = roundingIndex;
    }];
    [cycleView reloadData];
}

- (void)createCycleViewFour{
 
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    HyCycleView *cycleView = [self addCycleViewWithDirection:HyCycleViewDirectionBottom];
    [cycleView.configure roundingIndexChange:^(HyCycleView * _Nonnull cycleView, NSInteger indexs, NSInteger roundingIndex) {
        if (!pageControl.superview && indexs > 1) {
            CGFloat pageW = 15 * indexs;
            CGFloat pageH = 20;
            CGFloat pageX = - pageW / 2 + 10;
            CGFloat pageY = cycleView.frame.size.height - pageW / 2 - 15;
            pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
            [cycleView addSubview:pageControl];
            pageControl.numberOfPages = indexs;
        }
        pageControl.currentPage = indexs - roundingIndex - 1;
    }];
    [cycleView reloadData];
}

- (HyCycleView *)addCycleViewWithDirection:(HyCycleViewDirection)direction {
    
    CGFloat y = self.scrollView.subviews.count ? self.scrollView.subviews.lastObject.bottom : 0;
    HyCycleView *cycleView = [[HyCycleView alloc] initWithFrame:CGRectMake(30, y + 10, self.scrollView.width - 60, 130)];
    __weak typeof(self) _self = self;
    [[[[[[cycleView.configure direction:direction] totalIndexs:^NSInteger(HyCycleView * _Nonnull cycleView) {
        __strong typeof(_self) self = _self;
        return self.imageNameArray.count;
    }] viewWillAppearAtIndex:^(HyCycleView * _Nonnull cycleView, UIImageView *imageView, NSInteger index, BOOL isFirstLoad) {
        __strong typeof(_self) self = _self;
        if (isFirstLoad) {
            imageView.image = [UIImage imageNamed:self.imageNameArray[index]];
        }
    }] isCycle:YES] isAutoCycle:YES] viewProviderAtIndex:^id<HyCycleViewProviderProtocol> _Nonnull(HyCycleView * _Nonnull cycleView, NSInteger index) {
        __strong typeof(_self) self = _self;
        return self;
    }];
    [self.scrollView addSubview:cycleView];
    return cycleView;
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
