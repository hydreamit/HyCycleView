//
//  HyCyclePageView.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/15.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HyCyclePageView.h"
#import "HyCycleView.h"


@interface HyGestureTableView : UITableView <UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSArray<UIView *> *hy_otherGestureViews;
@end
@implementation HyGestureTableView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return
    self.hy_otherGestureViews.count &&
    [self.hy_otherGestureViews containsObject:otherGestureRecognizer.view];
}
@end



@interface HyCyclePageViewConfigure ()

@property (nonatomic,assign) HyCyclePageViewGestureStyle hy_gestureStyle;

@property (nonatomic,assign) HyCyclePageViewHeaderRefreshStyle  hy_headerRefreshStyle;
@property (nonatomic,assign) BOOL hy_isCycleLoop;
@property (nonatomic,assign) CGFloat hy_hoverOffset;
@property (nonatomic, assign) HyCycleViewScrollLoadStyle hy_loadStyle;

@property (nonatomic,strong) UIView *hy_headerView;
@property (nonatomic,assign) CGFloat hy_headerViewHeight;

@property (nonatomic,strong) UIView *hy_hoverView;
@property (nonatomic,assign) CGFloat hy_hoverViewHeight;

@property (nonatomic,assign) HyCyclePageViewHeaderViewUpAnimation hy_headerViewUpAnimation;
@property (nonatomic,assign) HyCyclePageViewHeaderViewDownAnimation hy_headerViewDownAnimation;

@property (nonatomic, assign) NSInteger hy_totalPage;
@property (nonatomic, assign) NSInteger hy_startPage;

@property (nonatomic,copy) Class(^hy_cyclePageClass)(HyCyclePageView *, NSInteger);
@property (nonatomic,copy) id (^hy_cyclePageInstance)(HyCyclePageView *, NSInteger);

@property (nonatomic, copy) void(^hy_viewWillAppear)(HyCyclePageView *,
                                                     id,
                                                     NSInteger,
                                                     BOOL);

@property (nonatomic, copy) void(^hy_currentPageChange)(HyCyclePageView *,
                                                      NSInteger,
                                                      NSInteger);

@property (nonatomic, copy) void(^hy_roundingPageChange)(HyCyclePageView *,
                                                         NSInteger,
                                                         NSInteger);

@property (nonatomic,copy) void (^hy_horizontalScroll)(HyCyclePageView *,
                                                       NSInteger,
                                                       NSInteger,
                                                       CGFloat);

@property (nonatomic,copy) void (^hy_verticalScroll)(HyCyclePageView *,
                                                     CGFloat ,
                                                     NSInteger);

@property (nonatomic,copy) void (^hy_headerRefresh)(HyCyclePageView *,
                                                    UIScrollView * ,
                                                    NSInteger);

@property (nonatomic,copy) void (^hy_footerRefresh)(HyCyclePageView *,
                                                    UIScrollView * ,
                                                    NSInteger);

@property (nonatomic,weak) HyCyclePageView *cyclePageView;
+ (instancetype)defaultConfigure;
@end


@interface HyCyclePageView ()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) HyCycleView *cycleView;
@property (nonatomic,strong) UIScrollView *contentScrollView;
@property (nonatomic,strong) HyCyclePageViewConfigure *configure;
@property (nonatomic,strong) NSMutableDictionary<NSNumber *, id> *pageInstancesDict;
@property (nonatomic,strong) NSMutableDictionary<NSNumber *, UIScrollView *> *pageScrollViewsDict;
@property (nonatomic,strong) NSMutableDictionary<NSNumber *, NSArray<UIGestureRecognizer *> *> *panGesturesDict;

@property (nonatomic,assign) HyCyclePageViewGestureStyle gestureStyle;
@property (nonatomic,strong) HyGestureTableView *gestureTableView;
@property (nonatomic,strong) UITableViewCell *gestureTableViewCell;
@property (nonatomic,assign) BOOL cellScrollViewCanScroll;
@property (nonatomic,assign) BOOL tableViewCanScroll;
@property (nonatomic,assign) CGFloat contentOffset;
@end


@implementation HyCyclePageView

+ (instancetype)cyclePageViewWithFrame:(CGRect)frame
                        configureBlock:(void (^)(HyCyclePageViewConfigure *configure))configureBlock {
    
    HyCyclePageView *pageView = [[self alloc] initWithFrame:frame];
    !configureBlock ?: configureBlock(pageView.configure);
    pageView.configure.cyclePageView = pageView;
    pageView.gestureStyle = pageView.configure.hy_gestureStyle;
    
    if (pageView.gestureStyle == HyCyclePageViewGestureStyleOnly) {
        [pageView addSubview:pageView.contentScrollView];
    } else {
        pageView.tableViewCanScroll = YES;
        pageView.cellScrollViewCanScroll =
        pageView.configure.hy_headerViewDownAnimation != HyCyclePageViewHeaderViewDownAnimationScale &&
        pageView.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleCenter &&
        pageView.configure.hy_headerRefresh;
        [pageView addSubview:pageView.gestureTableView];
    }
    return pageView;
}

- (void)scrollToNextPageWithAnimated:(BOOL)animated {
    [self.cycleView scrollToNextPageWithAnimated:animated];
}

- (void)scrollToLastPageWithAnimated:(BOOL)animated {
    [self.cycleView scrollToLastPageWithAnimated:animated];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
    [self.cycleView scrollToPage:page animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.headerView.backgroundColor = UIColor.redColor;
    
    if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
        
        self.contentScrollView.containTo(self);
        
        self.headerView.rectValue(0, 0, self.contentScrollView.width,
                                  self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
        
        if (self.configure.hy_headerView) {
            self.configure.hy_headerView.rectValue(0, 0, self.headerView.width, self.configure.hy_headerView.height);
        }
        
        if (self.configure.hy_hoverView) {
            self.configure.hy_hoverView.rectValue(0, self.configure.hy_headerView.bottom, self.headerView.width, self.configure.hy_hoverView.height);
        }
        
        self.cycleView.containTo(self.contentScrollView);
        
        [self updateCyclePageScrollViewContentInset];
        
    } else {
        
        self.gestureTableView.containTo(self);
        self.headerView.sizeIsEqualTo(self.configure.hy_headerView);
        self.cycleView.rectValue(0,0,self.gestureTableView.width, self.gestureTableView.height - self.configure.hy_hoverView.height - self.configure.hy_hoverOffset);
        
        self.gestureTableView.scrollEnabled =
        self.tableViewCanScroll = self.configure.hy_headerView.height > 0;
    }
}

- (void)updateCyclePageScrollViewContentInset {
    
    [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj,
                                                                     NSUInteger idx,
                                                                     BOOL *stop) {
        if ([obj isKindOfClass:UIScrollView.class]) {
            obj.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
            obj.contentOffset = CGPointMake(0, - self.headerView.height);
        }
    }];
}

- (void)updateHeaderViewWithNewView:(UIView *)newView
                            oldView:(UIView *)oldView {

    if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
        
        [oldView removeFromSuperview];
        
        if (newView) {
            [self.headerView addSubview:newView];
            newView.rectValue(0, 0, self.headerView.width, newView.height);
            if (self.configure.hy_hoverView) {
                self.configure.hy_hoverView.topValue(newView.height);
            }
            self.headerView.heightValue(newView.height + self.configure.hy_hoverView.height);
        } else {
            self.headerView.heightValue(self.configure.hy_hoverView.height);
        }
        
        [self updateCyclePageScrollViewContentInset];
        
    } else {
        
        [oldView removeFromSuperview];
        
        if (newView) {
            [self.headerView addSubview:newView];
            newView.rectValue(0, 0, self.headerView.width, newView.height);
        }
        self.headerView.sizeIsEqualTo(self.configure.hy_headerView);
        
        self.gestureTableView.scrollEnabled =
        self.tableViewCanScroll = newView.height > 0;
        
        [self.gestureTableView layoutIfNeeded];
        [self.gestureTableView setTableHeaderView:self.headerView];
    }
}

- (void)updateHeaderViewHeight {
    
    if (self.configure.hy_headerView) {
        self.configure.hy_headerView.heightValue(self.configure.hy_headerViewHeight);
        
        if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
            
            if (self.configure.hy_hoverView) {
                self.configure.hy_hoverView.topValue(self.configure.hy_headerView.height);
            }
            self.headerView.heightValue(self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
            [self updateCyclePageScrollViewContentInset];
            
        } else {
            
            self.configure.hy_headerView.heightValue(self.configure.hy_headerViewHeight);
            self.headerView.heightIsEqualTo(self.configure.hy_headerView);
            
            self.gestureTableView.scrollEnabled =
            self.tableViewCanScroll = self.configure.hy_headerView.height > 0;
            [self.gestureTableView layoutIfNeeded];
            [self.gestureTableView setTableHeaderView:self.headerView];
        }
    }
}

- (void)updateHoverViewWithNewView:(UIView *)newView
                           oldView:(UIView *)oldView {
    
    if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
        [oldView removeFromSuperview];
        
        if (newView) {
            [self.headerView addSubview:newView];
            newView.rectValue(0, self.configure.hy_headerView.bottom, self.headerView.width, newView.height);
            self.headerView.heightValue(newView.height + self.configure.hy_headerView.height);
        } else {
            self.headerView.heightValue(self.configure.hy_headerView.height);
        }
        [self updateCyclePageScrollViewContentInset];
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(.1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self.gestureTableView reloadData];
                       });
    }
}

- (void)updateHoverHeight {
   
    if (self.configure.hy_hoverView) {
        self.configure.hy_hoverView.heightValue(self.configure.hy_hoverViewHeight);
        
        if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
            self.headerView.heightValue(self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
            [self updateCyclePageScrollViewContentInset];
        } else {
            [self.gestureTableView reloadData];
        }
    }
}

- (void)updateTotalPage {
    
    [self clearData];
    if (self.configure.hy_cyclePageInstance &&
        self.configure.hy_cyclePageClass) {
        self.cycleView.configure.totalPage(self.configure.hy_totalPage);
    }
}

- (void)updateStartPage {
    self.cycleView.configure.startPage(self.configure.hy_startPage);
}

- (void)updateCyclePageClass {
    
    [self clearData];
    if (self.configure.hy_cyclePageClass) {
        self.cycleView.configure.totalPage(self.configure.hy_totalPage);
    }
}

- (void)updateCyclePageInstance {
    
    [self clearData];
    if (self.configure.hy_cyclePageInstance) {
        self.cycleView.configure.totalPage(self.configure.hy_totalPage);
    }
}

- (void)updateHoverOffset {

}

- (void)handleViewWithContainScrollView:(UIScrollView *)containScrollView
                            currentPage:(NSInteger)currentPage {
    
    containScrollView.showsHorizontalScrollIndicator = NO;
    containScrollView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        containScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    BOOL isHoverType = self.configure.hy_headerView.height;
    if (!isHoverType) {
        containScrollView.bounces = NO;
        containScrollView.scrollEnabled = NO;
    }
    
    id instance = nil;
    if (self.configure.hy_cyclePageClass) {
        
        Class clas = self.configure.hy_cyclePageClass(self, currentPage);
        NSString *classString = NSStringFromClass(clas);
        NSString *nibPath =  [[NSBundle mainBundle] pathForResource:classString ofType:@"nib"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:nibPath]) {
            instance = [[[NSBundle mainBundle] loadNibNamed:classString owner:nil options:nil] lastObject];
        } else {
           instance = [[clas alloc] init];
        }
        
    } else if (self.configure.hy_cyclePageInstance) {
        instance = self.configure.hy_cyclePageInstance(self, currentPage);
    }
    
    UIScrollView *observeScrollView = nil;
    
    if (instance) {
        
        [self.pageInstancesDict setObject:instance forKey:@(currentPage)];
        
        if ([instance isKindOfClass:UIViewController.class]) {
            
            containScrollView.alwaysBounceVertical = YES;
            
            UIViewController *controller = (UIViewController *)instance;
            UIView *customView = controller.view;
            
            containScrollView.contentSize = CGSizeMake(0, customView.height);
            customView.rectValue(0,0,containScrollView.width, customView.height);
            [containScrollView addSubview:customView];
            
            if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                containScrollView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
                containScrollView.contentOffset = [self getCurrentContentOffset];
                [self.panGesturesDict setObject:containScrollView.gestureRecognizers forKey:@(currentPage)];
            }
            
            observeScrollView = containScrollView;
            
        } else if ([instance isKindOfClass:UIScrollView.class]) {
            
            containScrollView.bounces = NO;
            containScrollView.scrollEnabled = NO;
            NSMutableArray *list = [NSMutableArray arrayWithArray:containScrollView.gestureRecognizers];
            [list enumerateObjectsUsingBlock:^(UIGestureRecognizer *obj,
                                                NSUInteger idx,
                                                BOOL * stop) {
                [containScrollView removeGestureRecognizer:obj];
            }];
            
            UIScrollView *scrollView = (UIScrollView *)instance;
            scrollView.alwaysBounceVertical = YES;
            if (@available(iOS 11.0, *)) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            
            scrollView.containTo(containScrollView);
            [containScrollView addSubview:scrollView];
            
            if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                scrollView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
                scrollView.contentOffset = [self getCurrentContentOffset];
                [self.panGesturesDict setObject:scrollView.gestureRecognizers forKey:@(currentPage)];
            }
            
            observeScrollView = scrollView;
            
        } else if ([instance isKindOfClass:UIView.class]) {
            
            containScrollView.alwaysBounceVertical = YES;
            
            UIView *customView = (UIView *)instance;
            containScrollView.contentSize = CGSizeMake(0, customView.height);
            customView.rectValue(0, 0, containScrollView.width, customView.height);
            [containScrollView addSubview:customView];
            
            if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                containScrollView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
                containScrollView.contentOffset = [self getCurrentContentOffset];
                [self.panGesturesDict setObject:containScrollView.gestureRecognizers forKey:@(currentPage)];
            }
            
            observeScrollView = containScrollView;
        }
    }
    
    if (observeScrollView) {
        [observeScrollView addObserver:self
                            forKeyPath:@"contentOffset"
                               options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                               context:(__bridge void * _Nullable)(@(currentPage))];
        [self.pageScrollViewsDict setObject:observeScrollView forKey:@(currentPage)];
        [self handleRefreshWithScrollView:observeScrollView index:currentPage];
    }
    
    if (self.gestureStyle == HyCyclePageViewGestureStyleMultiple &&
        self.headerView.height) {
        self.gestureTableView.hy_otherGestureViews = self.pageScrollViewsDict.allValues;
    }
}

- (CGPoint)getCurrentContentOffset {
    
    __block CGFloat contentOffsetY = - self.headerView.height;
    [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.contentOffset.y > contentOffsetY) {
            contentOffsetY = obj.contentOffset.y;
        }
    }];
    
    CGFloat hoverContentOffsetY = -(self.configure.hy_hoverView.height + self.configure.hy_hoverOffset);
    
    return CGPointMake(0, contentOffsetY >= hoverContentOffsetY ? hoverContentOffsetY : contentOffsetY);
}

- (void)clearData {
    
    [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj,
                                                           NSUInteger idx,
                                                           BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"contentOffset"];
    }];
    [self.pageScrollViewsDict removeAllObjects];
    [self.panGesturesDict removeAllObjects];
}

- (void)handleRefreshWithScrollView:(UIScrollView *)scrollView index:(NSInteger)index {
    
    if (self.configure.hy_headerRefresh) {
        if (self.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleTop) {
            
            if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                self.configure.hy_headerRefresh(self, scrollView, index);
            } else {
                if (!self.headerView.height) {
                    self.configure.hy_headerRefresh(self, scrollView, index);
                }
            }
            
        } else {
            self.configure.hy_headerRefresh(self, scrollView, index);
        }
    }
    
    if (self.configure.hy_footerRefresh) {
        self.configure.hy_footerRefresh(self, scrollView, index);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(UIScrollView *)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
   
    CGPoint newContentOffset =  [change[@"new"] CGPointValue];
    CGPoint oldContentOffset =  [change[@"old"] CGPointValue];
    NSInteger currentPage =  [((NSNumber *)(__bridge typeof(NSNumber *))context) integerValue];

    if (newContentOffset.y == oldContentOffset.y) {return;}
    
    if (self.configure.hy_headerView.height) {
        if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
            
            if (self.headerView.height) {
                
                CGFloat contentTop = self.headerView.height;
                
                CGFloat hoverOffset = (self.configure.hy_hoverView.height + self.configure.hy_hoverOffset);
                
                if (newContentOffset.y >= - hoverOffset) {
                    
                    self.headerView.top = - (self.headerView.height - hoverOffset);
                    
                } else if (newContentOffset.y <= - contentTop) {
                    
                    if (self.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleCenter) {
                        
                        self.headerView.rectValue(0, 0, self.contentScrollView.width, self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
                        
                        if (self.configure.hy_headerView) {
                            self.configure.hy_headerView.rectValue(0, 0, self.headerView.width, self.configure.hy_headerView.height);
                        }
                        
                        if (self.configure.hy_hoverView) {
                            self.configure.hy_hoverView.rectValue(0, self.configure.hy_headerView.bottom, self.headerView.width, self.configure.hy_hoverView.height);
                        }
                        
                    } else {
                        
                        self.headerView.top = - contentTop - newContentOffset.y;
                        
                        if (self.configure.hy_headerViewDownAnimation == HyCyclePageViewHeaderViewDownAnimationScale) {
                            
                            self.headerView.clipsToBounds = NO;
                            
                            if (self.configure.hy_headerView) {
                                
                                CGFloat heigth = self.headerView.height - self.configure.hy_hoverView.height;
                                
                                self.configure.hy_headerView
                                .topValue(-self.headerView.top)
                                .heightValue(heigth + self.headerView.top)
                                .widthValue(self.headerView.width + self.headerView.top)
                                .centerXIsEqualTo(self.configure.hy_hoverView);
                            }
                            
                            if (self.configure.hy_hoverView) {
                                self.configure.hy_hoverView.topValue(self.configure.hy_headerView.bottom);
                            }
                        }
                    }
                    
                } else {
                    
                    self.headerView.top = - contentTop - newContentOffset.y;
                    
                    if (self.configure.hy_headerViewUpAnimation == HyCyclePageViewHeaderViewUpAnimationCover &&
                        self.configure.hy_headerView) {
                        
                        self.headerView.clipsToBounds = YES;
                        CGFloat topView = - self.headerView.top * 2 / 3;
                        self.configure.hy_headerView.topValue(topView);
                    }
                    
                    self.configure.hy_headerView.heightValue(self.headerView.height - self.configure.hy_hoverView.height);
                }
                
                if (currentPage == self.cycleView.configure.currentPage) {
                    
                    if (newContentOffset.y <= - hoverOffset) {
                        if (newContentOffset.y >= - self.headerView.height) {
                            [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (object != obj) {
                                    if (obj.contentOffset.y >=  - self.headerView.height) {
                                        obj.contentOffset = newContentOffset;
                                    }
                                }
                            }];
                        }
                        
                    } else {
                        
                        [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (object != obj) {
                                if (obj.contentOffset.y < - hoverOffset) {
                                    obj.contentOffset = CGPointMake(0, -hoverOffset);
                                };
                            }
                        }];
                    }
                }
            }
            
        } else {
            
            if (currentPage == self.cycleView.configure.currentPage) {
                
                if (self.cellScrollViewCanScroll) {
                    !self.configure.hy_verticalScroll ?:
                    self.configure.hy_verticalScroll(self, newContentOffset.y + self.gestureTableView.contentOffset.y, self.cycleView.configure.currentPage);
                }
                
                BOOL isCenterRefresh =
                self.configure.hy_headerViewDownAnimation != HyCyclePageViewHeaderViewDownAnimationScale &&
                self.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleCenter &&
                self.configure.hy_headerRefresh;
                
                if (isCenterRefresh) {
                    
                    if (object.contentOffset.y == 0 &&
                        self.gestureTableView.contentOffset.y == 0) {
                        
                        self.cellScrollViewCanScroll =
                        self.tableViewCanScroll = YES;
                    }
                    
                    if (!self.cellScrollViewCanScroll) {
                        
                        object.contentOffset = CGPointZero;
                        
                    } else if (object.contentOffset.y < 0 &&
                               self.gestureTableView.contentOffset.y == self.headerView.height - self.configure.hy_hoverOffset) {
                        
                        object.contentOffset = CGPointZero;
                        self.cellScrollViewCanScroll = NO;
                        self.tableViewCanScroll = YES;
                        
                    } else if (object.contentOffset.y > 0 &&
                               self.gestureTableView.contentOffset.y < self.headerView.height - self.configure.hy_hoverOffset && self.gestureTableView.contentOffset.y >= 0) {
                        
                        object.contentOffset = CGPointZero;
                        self.cellScrollViewCanScroll = NO;
                        self.tableViewCanScroll = YES;
                    }
                    
                } else {
                    if (self.configure.hy_headerView.height) {
                        if (!self.cellScrollViewCanScroll) {
                            object.contentOffset = CGPointZero;
                        } else if (object.contentOffset.y <= 0) {
                            self.cellScrollViewCanScroll = NO;
                            self.tableViewCanScroll = YES;
                        }
                    }
                }
            }
        }
    }
    
    if (self.gestureStyle == HyCyclePageViewGestureStyleOnly &&
        currentPage == self.cycleView.configure.currentPage
        ) {
        !self.configure.hy_verticalScroll ?:
        self.configure.hy_verticalScroll(self, newContentOffset.y + object.contentInset.top, self.cycleView.configure.currentPage);
    }
}

#pragma mark — UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.gestureTableViewCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.configure.hy_hoverView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.height - self.configure.hy_hoverView.height - self.configure.hy_hoverOffset;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.configure.hy_hoverView.height;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat headerViewH = self.headerView.height;
    if (headerViewH) {
                
        if (self.tableViewCanScroll) {
            !self.configure.hy_verticalScroll ?:
            self.configure.hy_verticalScroll(self, scrollView.contentOffset.y, self.cycleView.configure.currentPage);
        }
        
        CGFloat contentOffsetY = scrollView.contentOffset.y;
        
        BOOL isCenterRefresh =
        self.configure.hy_headerViewDownAnimation != HyCyclePageViewHeaderViewDownAnimationScale &&
        self.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleCenter &&
        self.configure.hy_headerRefresh;
        
        if (isCenterRefresh) {
            
            UIScrollView *pageScrollView = [self.pageScrollViewsDict objectForKey:@(self.cycleView.configure.currentPage)];
            if ([pageScrollView isKindOfClass:UIScrollView.class]) {
                if (pageScrollView.contentOffset.y == 0 && scrollView.contentOffset.y == 0) {
                    self.tableViewCanScroll =
                    self.cellScrollViewCanScroll = YES;
                }
            }
            
            if (!self.tableViewCanScroll) {
                
                scrollView.contentOffset = CGPointMake(0, self.contentOffset);
                
            } else if (contentOffsetY >= headerViewH - self.configure.hy_hoverOffset) {
                
                self.contentOffset = headerViewH - self.configure.hy_hoverOffset;
                scrollView.contentOffset = CGPointMake(0, self.contentOffset);
                self.tableViewCanScroll = NO;
                self.cellScrollViewCanScroll = YES;
                
            } else if (contentOffsetY < 0) {
                
                self.contentOffset = 0;
                scrollView.contentOffset = CGPointMake(0, self.contentOffset);
                self.tableViewCanScroll = NO;
                self.cellScrollViewCanScroll = YES;
            }
            
        } else {
            
            CGFloat contentOffset = headerViewH - self.configure.hy_hoverOffset;
            if (!self.tableViewCanScroll) {
                scrollView.contentOffset = CGPointMake(0, contentOffset);
            } else if (scrollView.contentOffset.y >= contentOffset) {
                scrollView.contentOffset = CGPointMake(0, contentOffset);
                self.tableViewCanScroll = NO;
                self.cellScrollViewCanScroll = YES;
            }
        }

        if (self.configure.hy_headerViewDownAnimation == HyCyclePageViewHeaderViewDownAnimationScale &&
            contentOffsetY <= 0 &&
            !isCenterRefresh) {
            
            self.headerView.clipsToBounds = NO;
            self.configure.hy_headerView
            .topValue(contentOffsetY)
            .heightValue(headerViewH - contentOffsetY)
            .widthValue(self.headerView.width - contentOffsetY)
            .leftValue(contentOffsetY / 2);
        }
        
        if (self.configure.hy_headerViewUpAnimation == HyCyclePageViewHeaderViewUpAnimationCover &&
            contentOffsetY >= 0 && contentOffsetY <= headerViewH - self.configure.hy_hoverOffset) {
            
            self.headerView.clipsToBounds = YES;
            CGFloat topView = contentOffsetY * 2 / 3;
            self.configure.hy_headerView.topValue(topView);
        }
    }
}

- (void)setTableViewCanScroll:(BOOL)tableViewCanScroll {
    if (_tableViewCanScroll == tableViewCanScroll) { return;}
    
    _tableViewCanScroll = tableViewCanScroll;
    
    if (tableViewCanScroll) {
        [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj,
                                                                NSUInteger idx,
                                                                BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UIScrollView.class] && obj.contentOffset.y > 0) {
                [obj setContentOffset:CGPointZero];
            }
        }];
    }
}

#pragma mark — getters and setters
- (HyCyclePageViewConfigure *)configure {
    if (!_configure){
        _configure = [HyCyclePageViewConfigure defaultConfigure];
    }
    return _configure;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView){
        _contentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_contentScrollView addSubview:self.cycleView];
        [_contentScrollView addSubview:self.headerView];
    }
    return _contentScrollView;
}

- (HyGestureTableView *)gestureTableView {
    if (!_gestureTableView){
        
        _gestureTableView = [[HyGestureTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _gestureTableView.backgroundColor = UIColor.clearColor;
        _gestureTableView.delaysContentTouches = NO;
        _gestureTableView.canCancelContentTouches = YES;
        _gestureTableView.showsHorizontalScrollIndicator = NO;
        _gestureTableView.showsVerticalScrollIndicator = NO;
        _gestureTableView.panGestureRecognizer.cancelsTouchesInView = NO;
        if (@available(iOS 11.0, *)){
            _gestureTableView.estimatedRowHeight = 0;
            _gestureTableView.estimatedSectionHeaderHeight = 0;
            _gestureTableView.estimatedSectionFooterHeight = 0;
            _gestureTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _gestureTableView.sectionFooterHeight = 0.01;
        _gestureTableView.tableHeaderView = self.headerView;
        _gestureTableView.dataSource = self;
        _gestureTableView.delegate = self;
        
        if (self.configure.hy_headerRefresh &&
            self.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleTop &&
            self.configure.hy_headerViewDownAnimation != HyCyclePageViewHeaderViewDownAnimationScale &&
            self.headerView.height) {
            self.configure.hy_headerRefresh(self, _gestureTableView, 0);
        }
    }
    return _gestureTableView;
}

- (UITableViewCell *)gestureTableViewCell {
    if (!_gestureTableViewCell){
        _gestureTableViewCell = [[UITableViewCell alloc] init];
        _gestureTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _gestureTableViewCell.contentView.backgroundColor = UIColor.clearColor;
        [_gestureTableViewCell.contentView addSubview:self.cycleView];
    }
    return _gestureTableViewCell;
}

- (HyCycleView *)cycleView {
    if (!_cycleView){
        
        CGRect rect = self.bounds;
        if (self.gestureStyle == HyCyclePageViewGestureStyleMultiple) {
            rect = CGRectMake(0, 0, self.width, self.height - self.configure.hy_hoverView.height - self.configure.hy_hoverOffset);
        }
        
        __weak typeof(self) weakSelf = self;
        _cycleView = [HyCycleView cycleViewWithFrame:rect
                                      configureBlock:^(HyCycleViewConfigure *configure) {
           
                                          configure
                                          .scrollStyle(HyCycleViewScrollStatic)
                                          .loadStyle(weakSelf.configure.hy_loadStyle)
                                          .isCycleLoop(weakSelf.configure.hy_isCycleLoop)
                                          .totalPage(weakSelf.configure.hy_totalPage)
                                          .startPage(weakSelf.configure.hy_startPage)
                                          .cycleClasses(@[UIScrollView.class])
                                          .currentPageChange(^(HyCycleView *cycleView,
                                                               NSInteger totalPage,
                                                               NSInteger currentPage){
                                              
                                              if (weakSelf.configure.hy_headerView.height &&
                                                  weakSelf.gestureStyle == HyCyclePageViewGestureStyleOnly) {
                                                  
                                                  NSArray *panGes = [weakSelf.panGesturesDict objectForKey:@(currentPage)];
                                                  
                                                  if (panGes) {
                                                      NSMutableArray *list = [NSMutableArray arrayWithArray:weakSelf.contentScrollView.gestureRecognizers];
                                                      for (UIGestureRecognizer *gestureRecognizer in list) {
                                                          [weakSelf.contentScrollView removeGestureRecognizer:gestureRecognizer];
                                                      }
                                                      [weakSelf.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                          for (UIGestureRecognizer *gestureRecognizer in panGes) {
                                                              [obj addGestureRecognizer:gestureRecognizer];
                                                          };
                                                      }];
                                                      for (UIGestureRecognizer *gestureRecognizer in panGes) {
                                                          [weakSelf.contentScrollView addGestureRecognizer:gestureRecognizer];
                                                      };
                                                  }
                                              }
                                              
                                              !weakSelf.configure.hy_currentPageChange ?:
                                              weakSelf.configure.hy_currentPageChange(weakSelf, totalPage, currentPage);
                                          })
                                          .roundingPageChange(^(HyCycleView *cycleView,
                                                                NSInteger totalPage,
                                                                NSInteger roundingPage){
                                              
                                              !weakSelf.configure.hy_roundingPageChange ?:
                                              weakSelf.configure.hy_roundingPageChange(weakSelf, totalPage, roundingPage);
                                          })
                                          .scrollProgress(^(HyCycleView *cycleView, NSInteger fromPage, NSInteger toPage, CGFloat progress){
                                              
                                              !weakSelf.configure.hy_horizontalScroll ?:
                                              weakSelf.configure.hy_horizontalScroll(weakSelf, fromPage, toPage, progress);
                                          })
                                          .viewWillAppear(^(HyCycleView *cycleView,
                                                            id view,
                                                            NSInteger page,
                                                            BOOL isFirstLoad) {
                                              
                                              if (isFirstLoad) {
                                                  [weakSelf handleViewWithContainScrollView:view
                                                                                currentPage:page];
                                              }
                                             
                                              !weakSelf.configure.hy_viewWillAppear ?:
                                              weakSelf.configure.hy_viewWillAppear(weakSelf, [weakSelf.pageInstancesDict objectForKey:@(page)], page, isFirstLoad);
                                          });
        }];
    }
    return _cycleView;
}

- (UIView *)headerView {
    if (!_headerView){
        _headerView = [[UIView alloc] init];
        
        if (self.configure.hy_headerView) {
            [_headerView addSubview:self.configure.hy_headerView];
        }
        if (self.gestureStyle == HyCyclePageViewGestureStyleOnly) {
            if (self.configure.hy_hoverView) {
                [_headerView addSubview:self.configure.hy_hoverView];
            }
            _headerView.frame = CGRectMake(0, 0, self.width, self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
        } else {
            _headerView.frame = CGRectMake(0, 0, self.width, self.configure.hy_headerView.height);
        }
    }
    return _headerView;
}

- (NSMutableDictionary<NSNumber *,UIScrollView *> *)pageScrollViewsDict {
    if (!_pageScrollViewsDict){
        _pageScrollViewsDict = @{}.mutableCopy;
    }
    return _pageScrollViewsDict;
}

- (NSMutableDictionary<NSNumber *,NSArray<UIGestureRecognizer *> *> *)panGesturesDict {
    if (!_panGesturesDict){
        _panGesturesDict = @{}.mutableCopy;
    }
    return _panGesturesDict;
}

- (NSMutableDictionary<NSNumber *,id> *)pageInstancesDict {
    if (!_pageInstancesDict){
        _pageInstancesDict = @{}.mutableCopy;
    }
    return _pageInstancesDict;
}

- (void)dealloc {
    [self.pageScrollViewsDict.allValues enumerateObjectsUsingBlock:^(UIScrollView *obj,
                                                                     NSUInteger idx,
                                                                     BOOL *stop) {
        [obj removeObserver:self forKeyPath:@"contentOffset"];
    }];
}

@end


@implementation HyCyclePageViewConfigure
+ (instancetype)defaultConfigure {
    HyCyclePageViewConfigure *configure = [[self alloc] init];
    configure.isCycleLoop(YES).headerRefreshStyle(0);
    return configure;
}

- (HyCyclePageViewConfigure *(^)(HyCyclePageViewGestureStyle))gestureStyle {
    return ^HyCyclePageViewConfigure *(HyCyclePageViewGestureStyle style){
        self.hy_gestureStyle = style;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(HyCyclePageViewHeaderRefreshStyle))headerRefreshStyle {
    return ^HyCyclePageViewConfigure *(HyCyclePageViewHeaderRefreshStyle style) {
        self.hy_headerRefreshStyle = style;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(BOOL))isCycleLoop {
    return ^HyCyclePageViewConfigure *(BOOL cycleLoop) {
        self.hy_isCycleLoop = cycleLoop;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(HyCycleViewScrollLoadStyle))loadStyle {
    return ^HyCyclePageViewConfigure *(HyCycleViewScrollLoadStyle style) {
        self.hy_loadStyle = style;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(HyCyclePageViewHeaderViewUpAnimation))headerViewUpAnimation {
    return ^HyCyclePageViewConfigure *(HyCyclePageViewHeaderViewUpAnimation animation) {
        self.hy_headerViewUpAnimation = animation;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(HyCyclePageViewHeaderViewDownAnimation))headerViewDownAnimation {
    return ^HyCyclePageViewConfigure *(HyCyclePageViewHeaderViewDownAnimation animation) {
        self.hy_headerViewDownAnimation = animation;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(UIView *))headerView {
    return ^HyCyclePageViewConfigure *(UIView *view){
        self.hy_headerView = view;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(CGFloat ))headerViewHeight {
    return ^HyCyclePageViewConfigure *(CGFloat height){
        self.hy_headerViewHeight = height;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(UIView *))hoverView {
    return ^HyCyclePageViewConfigure *(UIView *view){
        self.hy_hoverView = view;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(CGFloat))hoverOffset {
    return ^HyCyclePageViewConfigure *(CGFloat offset){
        self.hy_hoverOffset = offset;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(CGFloat))hoverViewHeight {
    return ^HyCyclePageViewConfigure *(CGFloat height){
        self.hy_hoverViewHeight = height;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(NSInteger))startPage {
    return ^HyCyclePageViewConfigure *(NSInteger page){
        self.hy_startPage = page;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(NSInteger))totalPage {
    return ^HyCyclePageViewConfigure *(NSInteger page){
        self.hy_totalPage = page;
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(Class (^)(HyCyclePageView *, NSInteger)))cyclePageClass {
    return ^HyCyclePageViewConfigure *(Class (^block)(HyCyclePageView *, NSInteger)){
        self.hy_cyclePageClass = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(id (^)(HyCyclePageView *, NSInteger)))cyclePageInstance {
    return ^HyCyclePageViewConfigure *(id (^block)(HyCyclePageView *, NSInteger)){
        self.hy_cyclePageInstance = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         id,
                                         NSInteger,
                                         BOOL))
                                        )viewWillAppear {
    return ^HyCyclePageViewConfigure *(void (^block)(HyCyclePageView *,
                                                     id,
                                                     NSInteger,
                                                     BOOL)) {
        self.hy_viewWillAppear = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         NSInteger,
                                         NSInteger))
                                         )currentPageChange {
    return ^HyCyclePageViewConfigure *(void (^block)(HyCyclePageView *,
                                                     NSInteger,
                                                     NSInteger)) {
        self.hy_currentPageChange = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         NSInteger,
                                         NSInteger))
                                         )roundingPageChange {
    return ^HyCyclePageViewConfigure *(void (^block)(HyCyclePageView *,
                                                     NSInteger,
                                                     NSInteger)) {
        self.hy_roundingPageChange = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         NSInteger,
                                         NSInteger,
                                         CGFloat))
                                         )horizontalScroll {
    return ^HyCyclePageViewConfigure *(void (^block)(HyCyclePageView *,
                                                     NSInteger,
                                                     NSInteger,
                                                     CGFloat)) {
        self.hy_horizontalScroll = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         CGFloat,
                                         NSInteger))
                                         ) verticalScroll {
    return ^HyCyclePageViewConfigure *(void (^block)(HyCyclePageView *,
                                                     CGFloat,
                                                     NSInteger)) {
        self.hy_verticalScroll = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         UIScrollView *,
                                         NSInteger)))headerRefresh {
    
    return ^HyCyclePageViewConfigure *(void(^block)(HyCyclePageView *,
                                                    UIScrollView *,
                                                    NSInteger)) {
        self.hy_headerRefresh = [block copy];
        return self;
    };
}

- (HyCyclePageViewConfigure *(^)(void(^)(HyCyclePageView *,
                                         UIScrollView *,
                                         NSInteger)))footerRefresh {
    
    return ^HyCyclePageViewConfigure *(void(^block)(HyCyclePageView *,
                                                    UIScrollView *,
                                                    NSInteger)){
        self.hy_footerRefresh = [block copy];
        return self;
    };
}

- (void)setHy_totalPage:(NSInteger)hy_totalPage {
    _hy_totalPage = hy_totalPage;
    
    [self.cyclePageView updateTotalPage];
}

- (void)setHy_startPage:(NSInteger)hy_startPage {
    _hy_startPage = hy_startPage;
    
    [self.cyclePageView updateStartPage];
}

- (void)setHy_headerView:(UIView *)hy_headerView {
    
    [self.cyclePageView updateHeaderViewWithNewView:hy_headerView
                                            oldView:_hy_headerView];
    _hy_headerView = hy_headerView;
}

- (void)setHy_hoverView:(UIView *)hy_hoverView {
    
    [self.cyclePageView updateHoverViewWithNewView:hy_hoverView
                                           oldView:_hy_hoverView];
    _hy_hoverView = hy_hoverView;
}

- (void)setHy_headerViewHeight:(CGFloat)hy_headerViewHeight {
    _hy_headerViewHeight = hy_headerViewHeight;
    
    [self.cyclePageView updateHeaderViewHeight];
}

- (void)setHy_hoverViewHeight:(CGFloat)hy_hoverViewHeight {
    _hy_hoverViewHeight = hy_hoverViewHeight;
    
    [self.cyclePageView updateHoverHeight];
}

- (void)setHy_cyclePageClass:(Class (^)(HyCyclePageView *, NSInteger))hy_cyclePageClass {
    _hy_cyclePageClass = [hy_cyclePageClass copy];
    
    [self.cyclePageView updateCyclePageClass];
}

- (void)setHy_cyclePageInstance:(id (^)(HyCyclePageView *, NSInteger))hy_cyclePageInstance {
    _hy_cyclePageInstance = [hy_cyclePageInstance copy];
    
    [self.cyclePageView updateCyclePageInstance];
}

- (void)setHy_hoverOffset:(CGFloat)hy_hoverOffset {
    _hy_hoverOffset = hy_hoverOffset;
    
    [self.cyclePageView updateHoverOffset];
}

- (NSInteger)currentPage {
    return self.cyclePageView.cycleView.configure.currentPage;
}

@end
