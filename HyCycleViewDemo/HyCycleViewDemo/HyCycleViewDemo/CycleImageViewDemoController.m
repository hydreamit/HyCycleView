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


@interface CycleImageViewDemoController ()
@property (nonatomic,strong) NSArray<NSString *> *imageNameArray;
@property (nonatomic,strong) UIScrollView *scrollView;
@end


@implementation CycleImageViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    self.imageNameArray = @[@"one",@"two",@"three",@"four"];
    [self.view addSubview:self.scrollView];
    
    [self createCycleViewWithClass];
    [self createCycleViewWithClassBlock];
    [self createCycleViewWithInstance];
    [self createCycleViewWithMutiClass];
    
    self.scrollView.contentSize = CGSizeMake(0, self.scrollView.subviews.lastObject.bottom + 20);
}

- (void)createCycleViewWithClass {
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    
    __weak typeof(self) weakSelf = self;
    [self addCycleViewWithConfigreBlock:^(HyCycleViewConfigure *configure) {
        configure
        .totalPage(weakSelf.imageNameArray.count)
        .cycleClasses(@[UIImageView.class])
        .roundingPageChange(^(HyCycleView *cycleView,
                              NSInteger totalPage,
                              NSInteger currentPage){
            
            if (!pageControl.superview && totalPage > 1) {
                CGFloat pageW = 15 * totalPage;
                CGFloat pageH = 20;
                CGFloat pageX = (cycleView.frame.size.width - pageW) / 2;
                CGFloat pageY = cycleView.frame.size.height - pageH;
                pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                [cycleView addSubview:pageControl];
                pageControl.numberOfPages = totalPage;
            }
            pageControl.currentPage = currentPage;
        });
    }];
}

- (void)createCycleViewWithClassBlock {
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    
    __weak typeof(self) weakSelf = self;
    [self addCycleViewWithConfigreBlock:^(HyCycleViewConfigure *configure) {
        configure
        .scrollDirection(HyCycleViewScrollRight)
        .totalPage(weakSelf.imageNameArray.count)
        .cycleClass(^Class(HyCycleView *cycleView, NSInteger currentPage){
            return UIImageView.class;
        })
        .roundingPageChange(^(HyCycleView *cycleView,
                              NSInteger totalPage,
                              NSInteger currentPage){
            
            if (!pageControl.superview && totalPage > 1) {
                CGFloat pageW = 15 * totalPage;
                CGFloat pageH = 20;
                CGFloat pageX = cycleView.frame.size.width - pageW - 5;
                CGFloat pageY = cycleView.frame.size.height - pageH;
                pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                [cycleView addSubview:pageControl];
                pageControl.numberOfPages = totalPage;
            }
            pageControl.currentPage = totalPage - currentPage - 1;
        });
    }];
}

- (void)createCycleViewWithInstance {
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    
    [self addCycleViewWithConfigreBlock:^(HyCycleViewConfigure *configure) {
        configure
        .scrollDirection(HyCycleViewScrollTop)
        .cycleInstances(@[[UIImageView new], [UIImageView new], [UIImageView new], [UIImageView new]])
        .roundingPageChange(^(HyCycleView *cycleView,
                              NSInteger totalPage,
                              NSInteger currentPage){
            
            if (!pageControl.superview && totalPage > 1) {
                CGFloat pageW = 15 * totalPage;
                CGFloat pageH = 20;
                CGFloat pageX = cycleView.frame.size.width - pageW / 2 - 10;
                CGFloat pageY = cycleView.frame.size.height - pageW / 2 - 15;
                pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                [cycleView addSubview:pageControl];
                pageControl.numberOfPages = totalPage;
            }
            pageControl.currentPage = currentPage;
        });
    }];
}

- (void)createCycleViewWithMutiClass {
 
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    pageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    
    __weak typeof(self) weakSelf = self;
    [self addCycleViewWithConfigreBlock:^(HyCycleViewConfigure *configure) {
        configure
        .totalPage(weakSelf.imageNameArray.count)
        .scrollDirection(HyCycleViewScrollBottom)
        .cycleClasses(@[UIImageView.class,UIImageView.class,UIImageView.class,UIImageView.class])
        .roundingPageChange(^(HyCycleView *cycleView,
                              NSInteger totalPage,
                              NSInteger currentPage){
            
            if (!pageControl.superview && totalPage > 1) {
                CGFloat pageW = 15 * totalPage;
                CGFloat pageH = 20;
                CGFloat pageX = - pageW / 2 + 10;
                CGFloat pageY = cycleView.frame.size.height - pageW / 2 - 15;
                pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                [cycleView addSubview:pageControl];
                pageControl.numberOfPages = totalPage;
            }
            pageControl.currentPage = currentPage;
        });
    }];
}

- (void)addCycleViewWithConfigreBlock:(void(^)(HyCycleViewConfigure *configure))block {
    __weak typeof(self) weakSelf = self;
    
    CGFloat y = self.scrollView.subviews.count ? self.scrollView.subviews.lastObject.bottom : 0;
    [self.scrollView addSubview:
    [HyCycleView cycleViewWithFrame:CGRectMake(30, y + 10, self.scrollView.width - 60, 130)
                     configureBlock:^(HyCycleViewConfigure *configure) {
                         configure
                         .viewWillAppear(^(HyCycleView *cycleView,
                                           UIImageView *imageView,
                                           NSInteger index,
                                           BOOL isfirstLoad){
                             if (isfirstLoad) {
                                 imageView.contentMode = UIViewContentModeScaleAspectFill;
                                 imageView.image = [UIImage imageNamed:weakSelf.imageNameArray[index]];
                             }
                         })
                         .clickAction(^(HyCycleView *cycleView, NSInteger index){
                             
                             NSLog(@"clickAction====%tu", index);
                         });
                         !block ?: block(configure);
                     }]];
}

- (UIScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

@end
