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


@interface CycleCustomViewDemoController ()
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
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    
    [self.scrollView addSubview:
     [HyCycleView cycleViewWithFrame:CGRectMake(30, 10, self.scrollView.width - 60, 180)
                      configureBlock:^(HyCycleViewConfigure *configure) {
                          configure
                          .cycleClasses(@[HyCustomView.class])
                          .totalPage(dataArray.count)
                          .viewWillAppear(^(HyCycleView *cycleView,
                                            HyCustomView *customView,
                                            NSInteger index,
                                            BOOL isfirstLoad){
                              if (isfirstLoad) {
                                  [customView setDict:dataArray[index]];
                              }
                          })
                          .roundingPageChange(^(HyCycleView *cycleView,
                                                NSInteger totalPage,
                                                NSInteger currentPage){
                              
                              if (!pageControl.superview) {
                                  CGFloat pageW = 15 * totalPage;
                                  CGFloat pageH = 20;
                                  CGFloat pageX = cycleView.frame.size.width - pageW - 5;
                                  CGFloat pageY = cycleView.frame.size.height - pageH;
                                  pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                                  [cycleView addSubview:pageControl];
                                  pageControl.numberOfPages = totalPage;
                              }
                              pageControl.currentPage = currentPage;
                          });
                      }]];
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
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    
    [self.scrollView addSubview:
     [HyCycleView cycleViewWithFrame:CGRectMake(30, self.scrollView.subviews.lastObject.bottom + 10, self.scrollView.width - 60, 180)
                      configureBlock:^(HyCycleViewConfigure *configure) {
                          configure
                        .scrollDirection(1)
                          .totalPage(dataArray.count)
                          .cycleClass(^Class(HyCycleView *cycleView,
                                             NSInteger currentPage){
                              return currentPage % 2 ? UIImageView.class : HyCustomView.class;
                          })
                          .viewWillAppear(^(HyCycleView *cycleView,
                                            UIView *contentView,
                                            NSInteger index,
                                            BOOL isfirstLoad){
                              if (isfirstLoad) {
                                  if ([contentView isKindOfClass:HyCustomView.class]) {
                                      [((HyCustomView *)contentView) setDict:dataArray[index]];
                                  } else {
                                      ((UIImageView *)contentView).image = [UIImage imageNamed:dataArray[index][@"image"]];
                                  }
                              }
                          })
                          .roundingPageChange(^(HyCycleView *cycleView,
                                                NSInteger totalPage,
                                                NSInteger currentPage){
                              
                              if (!pageControl.superview) {
                                  CGFloat pageW = 15 * totalPage;
                                  CGFloat pageH = 20;
                                  CGFloat pageX = cycleView.frame.size.width - pageW - 5;
                                  CGFloat pageY = cycleView.frame.size.height - pageH;
                                  pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                                  [cycleView addSubview:pageControl];
                                  pageControl.numberOfPages = totalPage;
                              }
                              pageControl.currentPage = totalPage - 1 - currentPage;
                          });
                      }]];
}


- (void)createNoticeCycleView {
    
    NSArray *noticeArray = @[@"☪ 春眠不觉晓",
                             @"☪ 春眠不觉晓, 处处闻啼鸟",
                             @"☪ 春眠不觉晓, 处处闻啼鸟, 夜来风雨声",
                             @"☪ 春眠不觉晓, 处处闻啼鸟, 夜来风雨声, 花落知多少"];
    
    HyCycleView *cycleView =
    [HyCycleView cycleViewWithFrame:CGRectMake(30, self.scrollView.subviews.lastObject.bottom + 20, self.scrollView.width - 60, 45) configureBlock:^(HyCycleViewConfigure *configure) {
        
        configure
        .totalPage(noticeArray.count)
        .cycleClasses(@[UILabel.class])
        .scrollDirection(2)
        .viewWillAppear(^(HyCycleView *cycleView,
                          UILabel *label,
                          NSInteger index,
                          BOOL isfirstLoad){
            
            if (isfirstLoad) {
                label.textColor = UIColor.purpleColor;
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:13];
            }
            label.text = noticeArray[index];
        });
    }];
    
    cycleView.layer.borderColor = UIColor.purpleColor.CGColor;
    cycleView.layer.borderWidth = .5;
    cycleView.layer.cornerRadius = 5.0;
    cycleView.layer.masksToBounds = YES;
    
    [self.scrollView addSubview:cycleView];
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

@end
