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


@interface HyCyclePageViewConfigure ()

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

@property (nonatomic,strong) NSArray *hy_cyclePageInstances;
@property (nonatomic,copy) Class(^hy_cyclePageClass)(HyCyclePageView *, NSInteger);

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
                                                     UIScrollView *,
                                                     NSInteger);

@property (nonatomic,weak) HyCyclePageView *cyclePageView;
+ (instancetype)defaultConfigure;
@end


@interface HyCyclePageView ()<UIScrollViewDelegate>
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) HyCycleView *cycleView;
@property (nonatomic,strong) UIScrollView *contentScrollView;
@property (nonatomic,strong) HyCyclePageViewConfigure *configure;
@property (nonatomic,strong) NSMutableArray<NSArray *> *cyclePageGestures;
@property (nonatomic,strong) NSMutableArray<NSNumber *> *cyclePageFirstLoadflags;
@property (nonatomic,strong) NSMutableArray<UIScrollView *> *cyclePageScrollViews;
@property (nonatomic,strong) NSMutableArray<UIScrollView *> *observeScrollViews;
@property (nonatomic,strong) NSArray<UIGestureRecognizer *> *gestureRecognizers;
@property (nonatomic,strong) NSMutableDictionary<NSNumber *, UIViewController *> *controllersDict;
@end


@implementation HyCyclePageView

+ (instancetype)cyclePageViewWithFrame:(CGRect)frame
                        configureBlock:(void (^)(HyCyclePageViewConfigure *configure))configureBlock {
    
    HyCyclePageView *pageView = [[self alloc] initWithFrame:frame];

    !configureBlock ?: configureBlock(pageView.configure);
    pageView.configure.cyclePageView = pageView;
    [pageView addSubview:pageView.contentScrollView];
    [pageView.contentScrollView addSubview:pageView.cycleView];
    [pageView.contentScrollView addSubview:pageView.headerView];
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
}

- (void)updateCyclePageScrollViewContentInset {
    
    [self.cyclePageScrollViews enumerateObjectsUsingBlock:^(UIScrollView *obj,
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
}

- (void)updateHeaderViewHeight {
    
    if (self.configure.hy_headerView) {
        self.configure.hy_headerView.heightValue(self.configure.hy_headerViewHeight);
        if (self.configure.hy_hoverView) {
            self.configure.hy_hoverView.topValue(self.configure.hy_headerView.height);
        }
        self.headerView.heightValue(self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
        [self updateCyclePageScrollViewContentInset];
    }
}

- (void)updateHoverViewWithNewView:(UIView *)newView
                           oldView:(UIView *)oldView {
    
    [oldView removeFromSuperview];
    
    if (newView) {
        [self.headerView addSubview:newView];
        newView.rectValue(0, self.configure.hy_headerView.bottom, self.headerView.width, newView.height);
        self.headerView.heightValue(newView.height + self.configure.hy_headerView.height);
    } else {
        self.headerView.heightValue(self.configure.hy_headerView.height);
    }
    [self updateCyclePageScrollViewContentInset];
}

- (void)updateHoverHeight {
    
    if (self.configure.hy_hoverView) {
        self.configure.hy_hoverView.heightValue(self.configure.hy_hoverViewHeight);
        self.headerView.heightValue(self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
        [self updateCyclePageScrollViewContentInset];
    }
}

- (void)updateTotalPage {
    
    if (!self.configure.hy_cyclePageInstances.count &&
        self.configure.hy_cyclePageClass) {
        self.cycleView.configure.totalPage(self.configure.hy_totalPage);
    }
}

- (void)updateStartPage {
    self.cycleView.configure.startPage(self.configure.hy_startPage);
}

- (void)updateCyclePageClass {
    self.cycleView.configure.cycleInstances([self handleCyclePageInstance]);
}

- (void)updateCyclePageInstance {
    self.cycleView.configure.cycleInstances([self handleCyclePageInstance]);
}

- (void)updateHoverOffset {
    
}

- (void)handleGestureWithIndex:(NSInteger)index {
    
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.contentScrollView.gestureRecognizers];
    for (UIGestureRecognizer *gestureRecognizer in list) {
        [self.contentScrollView removeGestureRecognizer:gestureRecognizer];
    }

    [self.cyclePageScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (UIGestureRecognizer *gestureRecognizer in self.cyclePageGestures[idx]) {
            [obj addGestureRecognizer:gestureRecognizer];
        };
    }];

    for (UIGestureRecognizer *gestureRecognizer in self.cyclePageScrollViews[index].gestureRecognizers) {
        [self.contentScrollView addGestureRecognizer:gestureRecognizer];
    };
}

- (NSArray *)handleCyclePageInstance {
    
    [self.observeScrollViews enumerateObjectsUsingBlock:^(UIScrollView *obj,
                                                            NSUInteger idx,
                                                            BOOL *stop) {
       [obj removeObserver:self forKeyPath:@"contentOffset"];
    }];
    [self.observeScrollViews removeAllObjects];
    [self.cyclePageGestures removeAllObjects];
    [self.cyclePageScrollViews removeAllObjects];
    [self.cyclePageFirstLoadflags removeAllObjects];
    [self.controllersDict removeAllObjects];
    
    void (^handleView)(id, NSInteger) = ^(id instance, NSInteger index){
        
        UIScrollView *scrollView;
        
        if ([instance isKindOfClass:UIScrollView.class]) {
            
            scrollView = (UIScrollView *)instance;
            scrollView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
            scrollView.contentOffset = CGPointMake(0, - self.headerView.height);
            if (@available(iOS 11.0, *)) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            
            [self.cyclePageScrollViews addObject:scrollView];
            [self.cyclePageGestures addObject:scrollView.gestureRecognizers];
            
        } else {
            
            scrollView = [[UIScrollView alloc] init];
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            scrollView.contentInset = UIEdgeInsetsMake(self.headerView.height, 0, 0, 0);
            scrollView.contentOffset = CGPointMake(0, - self.headerView.height);
            if (@available(iOS 11.0, *)) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            
            if ([instance isKindOfClass:UIViewController.class]) {
                [self.controllersDict setObject:instance forKey:@(index)];
            } else {
                UIView *customView = (UIView *)instance;
                CGFloat contentSizeY = customView.height > self->_cycleView.height ? customView.height : self->_cycleView.height;
                scrollView.contentSize = CGSizeMake(0, contentSizeY);
                [scrollView addSubview:customView];
                customView.rectValue(0,0,customView.width, customView.height);
            }
            
            [self.cyclePageScrollViews addObject:scrollView];
            [self.cyclePageGestures addObject:scrollView.gestureRecognizers];
        }
        
        [scrollView addObserver:self
                     forKeyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                        context:nil];
        
        [self.observeScrollViews addObject:scrollView];
    };
    
    BOOL isHoverType = self.configure.hy_headerView.height;
    if (self.configure.hy_cyclePageInstances.count) {
        
        if (isHoverType) {
            for (id view in self.configure.hy_cyclePageInstances) {
                NSInteger index = [self.configure.hy_cyclePageInstances indexOfObject:view];
                handleView(view, index);
            }
        } else {
            self.cyclePageScrollViews = self.configure.hy_cyclePageInstances.mutableCopy;
        }
        
    } else if (self.configure.hy_cyclePageClass && self.configure.hy_totalPage) {
        
        for (NSInteger i = 0; i < self.configure.hy_totalPage; i++) {
            Class cls = self.configure.hy_cyclePageClass(self, i);
            id view = [[cls alloc] init];
            if (isHoverType) {
                handleView(view, i);
            } else {
                [self.cyclePageScrollViews addObject:view];
            }
        }
    }
    
    if (isHoverType) {
        [self.cyclePageScrollViews enumerateObjectsUsingBlock:^(UIScrollView *obj, NSUInteger idx, BOOL *stop) {
            [self.cyclePageFirstLoadflags addObject:@0];
        }];
    }
    
    return self.cyclePageScrollViews;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(UIScrollView *)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    CGPoint newContentOffset =  [change[@"new"] CGPointValue];
    CGPoint oldContentOffset =  [change[@"old"] CGPointValue];
    
    if (newContentOffset.y == oldContentOffset.y) {return;}
    
    if (self.headerView.height) {
        
        if (newContentOffset.y == - self.headerView.height) {
            NSInteger index = [self.cyclePageScrollViews indexOfObject:object];
            BOOL firstLoad = [[self.cyclePageFirstLoadflags objectAtIndex:index] boolValue];
            if (firstLoad) {
                object.contentOffset = oldContentOffset;
                return;
            }
        }
        
        CGFloat hoverOffset = (self.configure.hy_hoverView.height + self.configure.hy_hoverOffset);
        
        if (newContentOffset.y >= - hoverOffset) {
            
            self.headerView.top = - (self.headerView.height - hoverOffset);
            
        } else if (newContentOffset.y <= - object.contentInset.top) {
            
            if (self.configure.hy_headerRefreshStyle == HyCyclePageViewHeaderRefreshStyleCenter) {
                
                self.headerView.rectValue(0, 0, self.contentScrollView.width, self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
                
                if (self.configure.hy_headerView) {
                    self.configure.hy_headerView.rectValue(0, 0, self.headerView.width, self.configure.hy_headerView.height);
                }
                
                if (self.configure.hy_hoverView) {
                    self.configure.hy_hoverView.rectValue(0, self.configure.hy_headerView.bottom, self.headerView.width, self.configure.hy_hoverView.height);
                }
                
                
            } else {
                
                self.headerView.top = - object.contentInset.top - newContentOffset.y;
                
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
            
            self.headerView.top = - object.contentInset.top - newContentOffset.y;
            
            if (self.configure.hy_headerViewUpAnimation == HyCyclePageViewHeaderViewUpAnimationCover &&
                self.configure.hy_headerView) {

                self.headerView.clipsToBounds = YES;
                CGFloat topView = - self.headerView.top * 2 / 3;
                self.configure.hy_headerView.topValue(topView);
            }

            self.configure.hy_headerView.heightValue(self.headerView.height - self.configure.hy_hoverView.height);
        }
        
        if (object == self.cyclePageScrollViews[self.cycleView.configure.currentPage]) {
            
            if (newContentOffset.y <= - hoverOffset) {
                if (newContentOffset.y >= - self.headerView.height) {
                    [self.cyclePageScrollViews enumerateObjectsUsingBlock:^(UIScrollView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (object != obj) {
                            if (obj.contentOffset.y >=  - self.headerView.height) {
                                obj.contentOffset = newContentOffset;
                            }
                        }
                    }];
                }

            } else {
                
                [self.cyclePageScrollViews enumerateObjectsUsingBlock:^(UIScrollView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (object != obj) {
                        if (obj.contentOffset.y < - hoverOffset) {
                            obj.contentOffset = CGPointMake(0, -hoverOffset);
                        };
                    }
                }];
            }
        }
    }
    
    if (object == self.cyclePageScrollViews[self.cycleView.configure.currentPage]) {
        !self.configure.hy_verticalScroll ?:
        self.configure.hy_verticalScroll(self, object, self.cycleView.configure.currentPage);
    }
}

#pragma mark — getters and setters
- (HyCyclePageViewConfigure *)configure {
    if (!_configure){
        _configure = [HyCyclePageViewConfigure defaultConfigure];
    }
    return _configure;
}

- (HyCycleView *)cycleView {
    if (!_cycleView){
        __weak typeof(self) weakSelf = self;
        _cycleView = [HyCycleView cycleViewWithFrame:CGRectZero
                                      configureBlock:^(HyCycleViewConfigure *configure) {
           
                                          configure
                                          .scrollStyle(HyCycleViewScrollStatic)
                                          .loadStyle(weakSelf.configure.hy_loadStyle)
                                          .isCycleLoop(weakSelf.configure.hy_isCycleLoop)
                                          .totalPage(weakSelf.configure.hy_totalPage)
                                          .startPage(weakSelf.configure.hy_startPage)
                                          .cycleInstances([weakSelf handleCyclePageInstance])
                                          .currentPageChange(^(HyCycleView *cycleView,
                                                               NSInteger totalPage,
                                                               NSInteger currentPage){
                                              
                                              if (weakSelf.configure.hy_headerView.height) {
                                                  [weakSelf handleGestureWithIndex:currentPage];
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
                                                            BOOL isFirstLoad){
                                              
                                             id instance = view;
                                             BOOL isHoverType = weakSelf.configure.hy_headerView.height;
                                            
                                              if (isFirstLoad && isHoverType) {
                                                  
                                                  UIViewController *controller = [weakSelf.controllersDict objectForKey:@(page)];
                                                  if (controller) {
                                                      UIScrollView *scrollView = view;
                                                      UIView *customView = controller.view;
                                                                                                            
                                                      CGFloat contentSizeY = customView.height > scrollView.height ? customView.height : scrollView.height;
                                                      scrollView.contentSize = CGSizeMake(0, contentSizeY);
                                                      customView.rectValue(0,0,customView.width, customView.height);
                                                      [scrollView addSubview:customView];
                                                  }
                                                  
                                                  if (page < weakSelf.cyclePageFirstLoadflags.count) {
                                                      [weakSelf.cyclePageFirstLoadflags replaceObjectAtIndex:page withObject:@1];
                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                                                   (int64_t)(.1 * NSEC_PER_SEC)),
                                                                     dispatch_get_main_queue(), ^{
                                                                         [weakSelf.cyclePageFirstLoadflags replaceObjectAtIndex:page withObject:@0];
                                                                     });
                                                  }
                                              }
                                             
                                              !weakSelf.configure.hy_viewWillAppear ?:
                                              weakSelf.configure.hy_viewWillAppear(weakSelf, instance, page, isFirstLoad);
                                          });
                                      
        }];
        
    }
    return _cycleView;
}

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView){
        _contentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.bounces = NO;
        _contentScrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _contentScrollView;
}

- (UIView *)headerView {
    if (!_headerView){
        _headerView = [[UIView alloc] init];
        if (self.configure.hy_headerView) {
            [_headerView addSubview:self.configure.hy_headerView];
        }
        if (self.configure.hy_hoverView) {
            [_headerView addSubview:self.configure.hy_hoverView];
        }
        _headerView.frame = CGRectMake(0, 0, self.width, self.configure.hy_headerView.height + self.configure.hy_hoverView.height);
    }
    return _headerView;
}

- (NSMutableArray<UIScrollView *> *)cyclePageScrollViews {
    if (!_cyclePageScrollViews){
        _cyclePageScrollViews = @[].mutableCopy;
    }
    return _cyclePageScrollViews;
}

- (NSMutableArray<UIScrollView *> *)observeScrollViews {
    if (!_observeScrollViews){
        _observeScrollViews = @[].mutableCopy;
    }
    return _observeScrollViews;
}

- (NSMutableArray<NSNumber *> *)cyclePageFirstLoadflags {
    if (!_cyclePageFirstLoadflags){
        _cyclePageFirstLoadflags = @[].mutableCopy;;
    }
    return _cyclePageFirstLoadflags;
}

- (NSMutableArray<NSArray *> *)cyclePageGestures {
    if (!_cyclePageGestures){
        _cyclePageGestures = @[].mutableCopy;;
    }
    return _cyclePageGestures;
}

- (NSMutableDictionary<NSNumber *,UIViewController *> *)controllersDict {
    if (!_controllersDict){
        _controllersDict = @{}.mutableCopy;
    }
    return _controllersDict;
}


- (void)dealloc {
    [self.observeScrollViews enumerateObjectsUsingBlock:^(UIScrollView *obj,
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

- (HyCyclePageViewConfigure *(^)(NSArray *))cyclePageInstances {
    return ^HyCyclePageViewConfigure *(NSArray *array) {
        self.hy_cyclePageInstances = array;
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
                                         UIScrollView *,
                                         NSInteger))
                                         ) verticalScroll {
    return ^HyCyclePageViewConfigure *(void (^block)(HyCyclePageView *,
                                                     UIScrollView *,
                                                     NSInteger)) {
        self.hy_verticalScroll = [block copy];
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

- (void)setHy_cyclePageInstances:(NSArray<UIView *> *)hy_cyclePageInstances {
    _hy_cyclePageInstances = hy_cyclePageInstances;
    
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
