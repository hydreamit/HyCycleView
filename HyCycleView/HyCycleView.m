//
//  HyCycleView.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 16/5/3.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HyCycleView.h"


@interface HyGestureScrollView : UIScrollView <UIGestureRecognizerDelegate>
@end
@implementation HyGestureScrollView
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan &&
            self.contentOffset.x == 0) {
            return YES;
        }
    }
    return NO;
}
@end



@interface HyCycleViewConfigure ()
@property (nonatomic, assign) BOOL hy_isCycleLoop;
@property (nonatomic, assign) NSInteger hy_totalPage;
@property (nonatomic, assign) NSInteger hy_startPage;
@property (nonatomic, assign) NSTimeInterval hy_timeInterval;

@property (nonatomic, strong) NSArray *hy_cycleInstances;
@property (nonatomic, strong) NSArray<Class> *hy_cycleClasses;
@property (nonatomic, strong) Class(^hy_cycleClass)(HyCycleView *, NSInteger);

@property (nonatomic, assign) HyCycleViewScrollStyle hy_scrollStyle;
@property (nonatomic, assign) HyCycleViewScrollLoadStyle hy_loadStyle;
@property (nonatomic, assign) HyCycleViewScrollDirection hy_scrollDirection;
@property (nonatomic, copy) void(^hy_clickAction)(HyCycleView *, NSInteger);
@property (nonatomic, copy) void(^hy_viewWillAppear)(HyCycleView *,
                                                     id,
                                                     NSInteger,
                                                     BOOL);
@property (nonatomic, copy) void(^hy_currentPageChange)(HyCycleView *,
                                                        NSInteger,
                                                        NSInteger);

@property (nonatomic, copy) void(^hy_roundingPageChange)(HyCycleView *,
                                                         NSInteger,
                                                         NSInteger);

@property (nonatomic, copy) void(^hy_scrollProgress)(HyCycleView *,
                                                      NSInteger,
                                                      NSInteger,
                                                      CGFloat);
@property (nonatomic,weak) HyCycleView *cycleView;
+ (instancetype)defaultConfigure;
@end


@interface HyCycleView () <UIScrollViewDelegate>
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic,assign)  BOOL isSetPage;
@property (nonatomic, assign) CGFloat lastScrollProgress;
@property (nonatomic, assign) NSInteger lastFromIndex;
@property (nonatomic, assign) NSInteger lastToIndex;
@property (nonatomic, strong) HyGestureScrollView *scrollView;
@property (nonatomic, assign) NSInteger totalCycleCount;

@property (nonatomic, assign) NSInteger roundingCyclePage;
@property (nonatomic, assign) NSInteger currentCyclePage;

@property (nonatomic, strong) NSMutableArray *addedCycleViews;
@property (nonatomic, strong) HyCycleViewConfigure *configure;
@end


static int const CycleContentViewCount = 3;
@implementation HyCycleView
#pragma mark — public methods
+ (instancetype)cycleViewWithFrame:(CGRect)frame
                    configureBlock:(void (^)(HyCycleViewConfigure *configure))configureBlock {
    
    HyCycleView *cycleView = [[self alloc] initWithFrame:frame];
    
    [cycleView addSubview:cycleView.scrollView];
    !configureBlock ?: configureBlock(cycleView.configure);
    
    if (cycleView.configure.hy_cycleInstances.count) {
        
        cycleView.totalCycleCount = cycleView.configure.hy_cycleInstances.count;
        
    } else if (cycleView.configure.hy_cycleClasses.count) {
        
        if (cycleView.configure.hy_cycleClasses.count == 1 ||
            cycleView.configure.hy_totalPage <= cycleView.configure.hy_cycleClasses.count) {
            
            cycleView.totalCycleCount = cycleView.configure.hy_totalPage;
            
        } else {
            
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:cycleView.configure.hy_cycleClasses];
            NSInteger count = cycleView.configure.hy_totalPage - cycleView.configure.hy_cycleClasses.count;
            for (int i = 0; i < count; i++) {
                [mArray addObject:mArray.lastObject];
            }
            cycleView.configure.hy_cycleClasses = mArray.copy;
            cycleView.totalCycleCount = cycleView.configure.hy_totalPage;
        }
        
    } else if (cycleView.configure.hy_cycleClass) {
        
        cycleView.totalCycleCount = cycleView.configure.hy_totalPage;
    }
    
    if (cycleView.totalCycleCount > 0) {
        
        for (int i = 0; i < CycleContentViewCount; i++) {
            UIView *contentView = [[UIView alloc] init];
            contentView.backgroundColor = UIColor.clearColor;
            contentView.clipsToBounds = YES;
            [cycleView.scrollView addSubview:contentView];
            [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                               initWithTarget:cycleView
                                               action:@selector(tap:)]];
        }
        
        [cycleView handleStartCyclePage];
        [cycleView handleContentViewFrame];
        [cycleView handleScrollViewContentSize];
    
        cycleView.scrollView.scrollEnabled = cycleView.totalCycleCount != 1;
    }
    cycleView.configure.cycleView = cycleView;
    return cycleView;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto &&
        self.totalCycleCount > 1) {
        [self startTimer];
    }
}

- (void)scrollToNextPageWithAnimated:(BOOL)animated {
    [self scrollToNextPageWithAnimated:animated
                           handleTimer:YES];
}

- (void)scrollToNextPageWithAnimated:(BOOL)animated
                         handleTimer:(BOOL)handleTime {
    
    if (self.totalCycleCount <= 1) { return;}
    
    if (handleTime &&
        animated &&
        self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
        [self stopTimer];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(.25 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
                           [self startTimer];
                       });
    }
    
    NSInteger nextPage = [self getCurrentPage] + 1;
    nextPage = nextPage > self.totalCycleCount - 1 ? 0 : nextPage;
    [self scrollToPage:nextPage
              animated:animated];
}

- (void)scrollToLastPageWithAnimated:(BOOL)animated {
    
    if (self.totalCycleCount <= 1) { return;}
    
    NSInteger lastPage = [self getCurrentPage] - 1;
    lastPage = lastPage < 0 ? self.totalCycleCount - 1 : lastPage;
    [self scrollToPage:lastPage
              animated:animated];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
    
    if (self.totalCycleCount <= 1) { return;}
    
    if (page >= 0 && page < self.totalCycleCount) {
        
        if (self.scrollView.isDragging ||
            self.scrollView.isTracking ||
            self.scrollView.isDecelerating) {
            return;
        }
        
        NSInteger changePage = page - [self getCurrentPage];
        if (changePage == 0) { return;}
        
        NSInteger cycleIndex = page;
        if (self.configure.hy_scrollDirection == HyCycleViewScrollRight ||
            self.configure.hy_scrollDirection == HyCycleViewScrollBottom) {
            cycleIndex = self.totalCycleCount - 1 - page;
        }
        
        BOOL isNotCycleLoop =
        !self.configure.hy_isCycleLoop &&
        self.configure.hy_scrollStyle == HyCycleViewScrollStatic;
        
        
        if (isNotCycleLoop &&
            cycleIndex == self.totalCycleCount - 1) {
                        
            if (animated && self.currentCyclePage == 0) {
                [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                    [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
                [self addViewWithContentViewIndex:1
                                        pageIndex:self.currentCyclePage
                             isResetContentOffset:NO];
                self.scrollView.subviews[1].tag = self.currentCyclePage;
                self.lastFromIndex = self.currentCyclePage;
                self.lastToIndex = self.currentCyclePage;
                [self handleScrollViewToCenterWithAnimated:NO];
            }
            
            [self handleRightBottomContentViewTag];
            [self handleScrollViewToRightBottomWithAnimated:animated];
            
            if (!animated) {
                [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                    [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
                [self addViewWithContentViewIndex:2
                                        pageIndex:cycleIndex
                             isResetContentOffset:self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleDidAppear];
                self.currentCyclePage = cycleIndex;
                self.roundingCyclePage = cycleIndex;
            }
            
        } else if (isNotCycleLoop &&
                   cycleIndex == 0) {
            
            if (animated && self.currentCyclePage == self.totalCycleCount - 1) {
                [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                    [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
                [self addViewWithContentViewIndex:1
                                        pageIndex:self.currentCyclePage
                             isResetContentOffset:NO];
                self.scrollView.subviews[1].tag = self.currentCyclePage;
                self.lastFromIndex = self.currentCyclePage;
                self.lastToIndex = self.currentCyclePage;
                [self handleScrollViewToCenterWithAnimated:NO];
            }
            
            [self handleLeftTopContentViewTag];
            [self handleScrollViewToLeftTopWithAnimated:animated];
            
            if (!animated) {
                [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                    [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
                [self addViewWithContentViewIndex:0
                                        pageIndex:cycleIndex
                             isResetContentOffset:self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleDidAppear];
                self.currentCyclePage = cycleIndex;
                self.roundingCyclePage = cycleIndex;
            }
            
            
        } else if (isNotCycleLoop &&
                   (self.currentCyclePage == 0 || self.currentCyclePage == self.totalCycleCount - 1)) {
            
            for (int i = 0; i < self.scrollView.subviews.count; i++) {
                UIView *contentView = self.scrollView.subviews[i];
                NSInteger index = cycleIndex;
                if (i == 0) {
                    index --;
                } else if (i == 2) {
                    index ++;
                }
                if (index < 0) {
                    index = self.totalCycleCount - 1;
                } else if (index >= self.totalCycleCount) {
                    index = 0;
                }
                contentView.tag = index;
            }
            
            [self.scrollView.subviews[1].subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self addViewWithContentViewIndex:1
                                    pageIndex:cycleIndex
                         isResetContentOffset:self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleDidAppear];
            
            [self handleScrollViewToCenterWithAnimated:animated];
            
            if (!animated) {
                self.currentCyclePage = cycleIndex;
                self.roundingCyclePage = cycleIndex;
            }
            
        } else {
            
            if (animated) {
                
                BOOL isNext =
                (changePage > 0 && changePage != self.totalCycleCount - 1) ||
                changePage == 1 - self.totalCycleCount;
                if (self.totalCycleCount == 2) {
                    isNext = cycleIndex == 1;
                }
                
                BOOL isJump =
                changePage != 1 &&
                changePage != -1 &&
                changePage != 1 - self.totalCycleCount &&
                changePage !=  self.totalCycleCount - 1;
                
                BOOL isLeftTop =
                self.configure.hy_scrollDirection == HyCycleViewScrollLeft||
                self.configure.hy_scrollDirection == HyCycleViewScrollTop;
                
                if (isJump) {
                    
                    NSInteger indess = 0;
                    if (isLeftTop) {
                        if (isNext > 0) {
                            indess = page - 1;
                            if (indess < 0) {
                                indess = self.totalCycleCount - 1;
                            }
                        } else {
                            indess = page + 1;
                            if (indess > self.totalCycleCount - 1) {
                                indess = 0;
                            }
                        }
                    } else {
                        
                        if (isNext) {
                            indess = self.totalCycleCount - page;
                            if (indess > self.totalCycleCount - 1) {
                                indess = 0;
                            }
                        } else {
                            indess = (self.totalCycleCount - 1 - page) - 1;
                            if (indess < 0) {
                                indess = self.totalCycleCount - 1;
                            }
                        }
                    }
                    
                    NSInteger centerTag = indess;
                    NSInteger leftTag = indess - 1 < 0 ?  (self.totalCycleCount - 1) : indess - 1;
                    NSInteger rightTag = indess + 1 > self.totalCycleCount - 1 ? 0 : indess + 1;
                    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                        if (idx == 0) {
                            obj.tag = leftTag;
                        } else if (idx == 2) {
                            obj.tag = rightTag;
                        } else {
                            obj.tag = centerTag;
                        }
                    }];
                }
                
                if (isNext) {
                    
                    switch (self.configure.hy_scrollDirection) {
                        case HyCycleViewScrollLeft: {
                            [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.width, 0)
                                                     animated:animated];
                        }break;
                        case HyCycleViewScrollRight:
                        case HyCycleViewScrollBottom: {
                            [self.scrollView setContentOffset:CGPointZero animated:animated];
                        }break;
                        case HyCycleViewScrollTop: {
                            [self.scrollView setContentOffset:CGPointMake(0, 2 * self.scrollView.height)
                                                     animated:animated];
                        }break;
                        default:
                        break;
                    }
                    
                } else {
                    
                    switch (self.configure.hy_scrollDirection) {
                        case HyCycleViewScrollLeft:
                        case HyCycleViewScrollTop:{
                            [self.scrollView setContentOffset:CGPointZero
                                                     animated:animated];
                        }break;
                        case HyCycleViewScrollRight: {
                            [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.width, 0)
                                                     animated:animated];
                        }break;
                        case HyCycleViewScrollBottom: {
                            [self.scrollView setContentOffset:CGPointMake(0, 2 * self.scrollView.height)
                                                     animated:animated];
                        }break;
                        default:
                        break;
                    }
                }
                
            } else {
                
                self.currentCyclePage = cycleIndex;
                self.roundingCyclePage = cycleIndex;
                [self handleContentViewTag];
                [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                    [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                }];
                [self addViewWithContentViewIndex:1
                                        pageIndex:self.currentCyclePage
                             isResetContentOffset:self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleDidAppear];
            }
        }
    }
}

- (void)updateTotalPage {
    
    if (!self.configure.hy_cycleInstances.count &&
        self.configure.hy_cycleClasses.count) {
        
        if (self.configure.hy_cycleClasses.count == 1 ||
            self.configure.hy_totalPage <= self.configure.hy_cycleClasses.count) {
            self.totalCycleCount = self.configure.hy_totalPage;
        } else {
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.configure.hy_cycleClasses];
            NSInteger count = self.configure.hy_totalPage - self.configure.hy_cycleClasses.count;
            for (int i = 0; i < count; i++) {
                [mArray addObject:mArray.lastObject];
            }
            self.configure.hy_cycleClasses = mArray.copy;
            self.totalCycleCount = self.configure.hy_totalPage;
        }
        
        [self handleStartCyclePage];
        [self handleScrollViewAndContentView];
        
        if (self.totalCycleCount == 1) {
            self.scrollView.scrollEnabled = NO;
            if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
                [self stopTimer];
            }
        } else {
            self.scrollView.scrollEnabled = YES;
            if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
                [self stopTimer];
                [self startTimer];
            }
        }
    } else {
        [self clearData];
    }
}

- (void)clearData {
    self.totalCycleCount = 0;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
    [self handleStartCyclePage];
    [self stopTimer];
}


- (void)updateStartPage {
    
    [self handleStartCyclePage];
    [self handleScrollViewAndContentView];
    [self updateTimeInterval];
}

- (void)updateTimeInterval {
    
    if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
        [self stopTimer];
        [self startTimer];
    }
}

- (void)updateCycleClasses {
    
    [self updateTotalPage];
}

- (void)updateCycleClass {
    
    if (self.configure.hy_cycleClass) {
        if (!self.configure.hy_cycleInstances.count &&
            !self.configure.hy_cycleClasses.count) {
            
            self.totalCycleCount = self.configure.hy_totalPage;
            [self handleStartCyclePage];
            [self handleScrollViewAndContentView];
        }
    } else {
        [self clearData];
    }
}

- (void)updateCycleInstances {
    
    self.totalCycleCount = self.configure.hy_cycleInstances.count;
    if (self.totalCycleCount) {
        
        [self handleStartCyclePage];
        [self handleScrollViewAndContentView];
        
        if (self.totalCycleCount == 1) {
            self.scrollView.scrollEnabled = NO;
            if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
                [self stopTimer];
            }
        } else {
            self.scrollView.scrollEnabled = YES;
            if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
                [self stopTimer];
                [self startTimer];
            }
        }
        
    } else {
        [self clearData];
    }
}

- (void)updateScrollStyle {
    
    [self handleStartCyclePage];
    [self handleScrollViewAndContentView];
    if (self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
        [self stopTimer];
        [self startTimer];
    } else {
        [self stopTimer];
    }
}

- (void)updateScrollDirection {
    
    [self updateScrollStyle];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.containTo(self);
    [self handleContentViewFrame];
    [self handleScrollViewContentSize];
    [self handleScrollViewAndContentView];
    
    !self.configure.hy_currentPageChange ?:
    self.configure.hy_currentPageChange(self, self.totalCycleCount, self.currentCyclePage);
    
    !self.configure.hy_roundingPageChange ?:
    self.configure.hy_roundingPageChange(self, self.totalCycleCount, self.currentCyclePage);
}

- (void)handleScrollViewAndContentView {
    
    if ([self isNotCycleLoop]) {
        
        switch (self.configure.hy_scrollDirection) {
            case HyCycleViewScrollLeft:
            case HyCycleViewScrollRight:{
                if (self.currentCyclePage == 0) {
                    [self handleLeftTopContentViewTag];
                    self.scrollView.contentOffset = CGPointZero;
                } else {
                    [self handleRightBottomContentViewTag];
                    self.scrollView.contentOffset = CGPointMake(2 * self.scrollView.width, 0);
                }
            }break;
            case HyCycleViewScrollTop:
            case HyCycleViewScrollBottom: {
                if (self.currentCyclePage == 0) {
                    [self handleLeftTopContentViewTag];
                    self.scrollView.contentOffset = CGPointZero;
                } else {
                    [self handleRightBottomContentViewTag];
                    self.scrollView.contentOffset = CGPointMake(0, 2 * self.scrollView.height);
                }
            }break;
            default:
                break;
        }
        
        NSInteger loadOnIndex = 0;
        if (self.scrollView.contentOffset.x != 0 ||
            self.scrollView.contentOffset.y != 0) {
            loadOnIndex = 2;
        }
        [self addViewWithContentViewIndex:loadOnIndex
                                pageIndex:self.currentCyclePage
                     isResetContentOffset:self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleDidAppear];
        
    } else {
        
        [self handleContentViewTag];
        [self handleScrollViewToCenterWithAnimated:NO];
        [self addViewWithContentViewIndex:1
                                pageIndex:self.currentCyclePage
                     isResetContentOffset:self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleDidAppear];
    }
}

- (void)handleLeftTopContentViewTag {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj,
                                                           NSUInteger idx,
                                                           BOOL *stop) {
        obj.tag = idx;
    }];
}

- (void)handleRightBottomContentViewTag {
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj,
                                                           NSUInteger idx,
                                                           BOOL *stop) {
        if (idx == 2) {
            obj.tag = self.totalCycleCount - 1;
        } else if (idx == 1) {
            obj.tag = self.totalCycleCount - 2;
        } else {
            obj.tag = self.totalCycleCount - 3;
        }
    }];
}

#pragma mark — prevate methods
- (void)handleScrollViewContentSize {
    
    switch (self.configure.hy_scrollDirection) {
        case HyCycleViewScrollLeft:
        case HyCycleViewScrollRight:{
            self.scrollView.contentSize = CGSizeMake(CycleContentViewCount * self.width, 0);
        }break;
        case HyCycleViewScrollTop:
        case HyCycleViewScrollBottom:{
            self.scrollView.contentSize = CGSizeMake(0, CycleContentViewCount * self.height);
        }break;
        default:
        break;
    }
}

- (void)handleContentViewFrame {
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj,
                                                           NSUInteger idx,
                                                           BOOL *stop) {
        
        switch (self.configure.hy_scrollDirection) {
            case HyCycleViewScrollLeft:
            case HyCycleViewScrollRight: {
                obj.rectValue(idx * self.scrollView.width,
                                      0,
                                      self.scrollView.width,
                                      self.scrollView.height);
            }break;
            case HyCycleViewScrollTop:
            case HyCycleViewScrollBottom: {
                obj.rectValue(0,
                                      idx * self.scrollView.height,
                                      self.scrollView.width,
                                      self.scrollView.height);
            }break;
            default:
            break;
        }
        [obj.subviews enumerateObjectsUsingBlock:^(UIView *subObj,
                                                   NSUInteger idx,
                                                   BOOL *stop) {
            subObj.containTo(obj);
        }];
    }];
}

- (void)handleScrollViewToCenterWithAnimated:(BOOL)animated {
    
    switch (self.configure.hy_scrollDirection) {
        case HyCycleViewScrollLeft:
        case HyCycleViewScrollRight: {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0)
                                     animated:animated];
        }break;
        case HyCycleViewScrollTop:
        case HyCycleViewScrollBottom: {
            [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.height)
                                     animated:animated];
        }break;
        default:
        break;
    }
}

- (void)handleScrollViewToLeftTopWithAnimated:(BOOL)animated {
    [self.scrollView setContentOffset:CGPointZero
                             animated:animated];
}

- (void)handleScrollViewToRightBottomWithAnimated:(BOOL)animated {
    switch (self.configure.hy_scrollDirection) {
        case HyCycleViewScrollLeft:
        case HyCycleViewScrollRight: {
            [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.width, 0)
                                     animated:animated];
        }break;
        case HyCycleViewScrollTop:
        case HyCycleViewScrollBottom:{
            [self.scrollView setContentOffset:CGPointMake(0, 2 * self.scrollView.height)
                                     animated:animated];
        }break;
        default:
        break;
    }
}

- (void)handleStartCyclePage {
    
    switch (self.configure.hy_scrollDirection) {
        case HyCycleViewScrollLeft:
        case HyCycleViewScrollTop:{
            NSInteger startIndex = self.configure.hy_startPage;
            if (startIndex > self.totalCycleCount - 1) {
                startIndex = 0;
            }
            self.currentCyclePage = startIndex;
            self.roundingCyclePage = startIndex;
        }break;
        case HyCycleViewScrollRight:
        case HyCycleViewScrollBottom:{
            NSInteger startIndex = self.totalCycleCount - 1 - self.configure.hy_startPage;
            if (startIndex < 0) {
                startIndex = self.totalCycleCount - 1;
            }
            self.currentCyclePage = startIndex;
            self.roundingCyclePage = startIndex;
        }break;
        default:
        break;
    }
    
    self.lastFromIndex = self.currentCyclePage;
    self.lastToIndex = self.currentCyclePage;
    
    !self.configure.hy_currentPageChange ?:
    self.configure.hy_currentPageChange(self, self.totalCycleCount, self.configure.hy_startPage);
    
    !self.configure.hy_roundingPageChange ?:
    self.configure.hy_roundingPageChange(self, self.totalCycleCount, self.configure.hy_startPage);
}


- (void)handleContentViewTag {
    
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *contentView = self.scrollView.subviews[i];
        NSInteger index = self.currentCyclePage;
        if (i == 0) {
            index --;
        } else if (i == 2) {
            index ++;
        }
        
        if (index < 0) {
            index = self.totalCycleCount - 1;
        } else if (index >= self.totalCycleCount) {
            index = 0;
        }
        contentView.tag = index;
    }
}

- (BOOL)isNotCycleLoop {
    return !self.configure.hy_isCycleLoop &&
    self.configure.hy_scrollStyle == HyCycleViewScrollStatic &&
    self.totalCycleCount > 2 &&
    (self.currentCyclePage == 0 || self.currentCyclePage == self.totalCycleCount - 1);
}

- (void)updateContentOffsetAndContentView {
    
    if (!self.scrollView.subviews.count) {return;}
    
    self.currentCyclePage = self.roundingCyclePage;
    
    if ([self isNotCycleLoop]) {
        
        NSInteger loadOnIndex = 0;
        switch (self.configure.hy_scrollDirection) {
            case HyCycleViewScrollLeft:
            case HyCycleViewScrollRight:{
                if (self.scrollView.contentOffset.x > self.scrollView.width) {
                    loadOnIndex = 2;
                }
            }break;
            case HyCycleViewScrollTop:
            case HyCycleViewScrollBottom:{
                if (self.scrollView.contentOffset.y > self.scrollView.height) {
                    loadOnIndex = 2;
                }
            }break;
            default:
            break;
        }
        
        [self addViewWithContentViewIndex:loadOnIndex
                                pageIndex:self.currentCyclePage
                     isResetContentOffset:YES];
        
         return;
    }
    

    [self handleContentViewTag];
    [self handleScrollViewToCenterWithAnimated:NO];
   
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
    [self addViewWithContentViewIndex:1
                            pageIndex:self.currentCyclePage
                 isResetContentOffset:YES];
}

- (void)addViewWithContentViewIndex:(NSInteger)index
                          pageIndex:(NSInteger)pageIndex
               isResetContentOffset:(BOOL)isResetContentOffset {
    
    if (self.scrollView.subviews.count == 0 ||
        index > self.scrollView.subviews.count - 1) {
        return;
    }
    
    UIView *contentView = self.scrollView.subviews[index];
    if (contentView.subviews.count) {return;}
    
    NSInteger dataIndex = pageIndex;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollLeft ||
        self.configure.hy_scrollDirection == HyCycleViewScrollTop) {
        if (dataIndex > self.totalCycleCount - 1) {
            dataIndex = 0;
        }
    } else {
        dataIndex = self.totalCycleCount - 1 - pageIndex;
        if (dataIndex < 0) {
            dataIndex = self.totalCycleCount - 1;
        }
    }

    BOOL isfistrLoad = NO;
    UIView *willAddView = [self.addedCycleViews objectAtIndex:dataIndex];
    
//    NSArray *viewArray = [self getAddedCycleViewWithIndex:dataIndex];
//    UIView *willAddView = viewArray.firstObject;
//    BOOL isfistrLoad = ![viewArray.lastObject boolValue];
    
    if (![willAddView isKindOfClass:UIView.class] &&
        ![willAddView isKindOfClass:UIViewController.class]) {
        
        if (self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleWillAppear) {
            
            if (self.configure.hy_cycleInstances.count) {
                willAddView = self.configure.hy_cycleInstances[dataIndex];
            } else {
                willAddView = [self createViewWithIndex:dataIndex];
            }
            isfistrLoad = YES;
            
        } else {
            
            if (isResetContentOffset) {
                if (self.configure.hy_cycleInstances.count) {
                    willAddView = self.configure.hy_cycleInstances[dataIndex];
                } else {
                    willAddView = [self createViewWithIndex:dataIndex];
                }
                isfistrLoad = YES;
            }
        }
    //  [self.addedCycleViews addObject:willAddView];
    }
    
//    !self.configure.hy_viewWillAppear ?:
//    self.configure.hy_viewWillAppear(self, willAddView, dataIndex, isfistrLoad);
    
    if ([willAddView isKindOfClass:UIView.class] ||
        [willAddView isKindOfClass:UIViewController.class]) {
        
        [self addingCycleView:willAddView index:dataIndex];
        
        if (self.configure.hy_loadStyle == HyCycleViewScrollLoadStyleWillAppear) {
            if (!isResetContentOffset) {
                !self.configure.hy_viewWillAppear ?:
                self.configure.hy_viewWillAppear(self, willAddView, dataIndex, isfistrLoad);
            }
        } else {
            
            if (isfistrLoad) {
                !self.configure.hy_viewWillAppear ?:
                self.configure.hy_viewWillAppear(self, willAddView, dataIndex, isfistrLoad);
            } else {
                if (!isResetContentOffset) {
                    !self.configure.hy_viewWillAppear ?:
                    self.configure.hy_viewWillAppear(self, willAddView, dataIndex, isfistrLoad);
                }
            }
        }
        
        if ([willAddView isKindOfClass:UIViewController.class]) {
            UIViewController *vc = (UIViewController *)willAddView;
            vc.view.containTo(contentView);
            [contentView addSubview:vc.view];
        } else {
            
            ((UIView *)willAddView).containTo(contentView);
            [contentView addSubview:willAddView];
        }
    }
}

- (UIView *)createViewWithIndex:(NSInteger)index {
    
    Class class;
    if (self.configure.hy_cycleClasses.count) {
        
        class =
        self.configure.hy_cycleClasses.count == 1 ?
        self.configure.hy_cycleClasses.firstObject :
        self.configure.hy_cycleClasses[index];
        
    } else if (self.configure.hy_cycleClass) {
        
        class = self.configure.hy_cycleClass(self, index);
    }
    
    NSString *classString = NSStringFromClass(class);
    NSString *nibPath =  [[NSBundle mainBundle] pathForResource:classString ofType:@"nib"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:nibPath]) {
        return [[[NSBundle mainBundle] loadNibNamed:classString owner:nil options:nil] lastObject];
    } else {
        return  [[class alloc] init];
    }
}

- (void)addingCycleView:(UIView *)view index:(NSInteger)index {
    if (view && ![self.addedCycleViews containsObject:view]) {
        [self.addedCycleViews replaceObjectAtIndex:index withObject:view];
    }
}

- (id)getAddedCycleViewWithIndex:(NSInteger)index {
    
    __block id instance = @1;
    __block BOOL haveCreate = NO;
    
    if (self.addedCycleViews.count) {
        
        if (self.configure.hy_cycleInstances.count) {
            
            id object = self.configure.hy_cycleInstances[index];
            [self.addedCycleViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (obj == object) {
                    instance = obj;
                    haveCreate = YES;
                    *stop = YES;
                }
            }];
            
        } else if (self.configure.hy_cycleClasses.count ||
                   self.configure.hy_cycleClass) {
            
            Class class;
            if (self.configure.hy_cycleClasses.count) {
                class =
                self.configure.hy_cycleClasses.count == 1 ?
                self.configure.hy_cycleClasses.firstObject :
                self.configure.hy_cycleClasses[index];
                
            } else if (self.configure.hy_cycleClass) {
                class = self.configure.hy_cycleClass(self, index);
            }
            
            [self.addedCycleViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if ([obj isMemberOfClass:class]) {
                    
                    UIView *view = obj;
                    if ([obj isKindOfClass:UIViewController.class]) {
                        view = ((UIViewController *)obj).view;
                    }
                    haveCreate = YES;
                    if (!view.superview) {
                        instance = obj;
                        *stop = YES;
                    }
                }
            }];
        }
    }
    
    return @[instance , @(haveCreate)];
}

- (NSInteger)getCurrentPage {
    
    NSInteger currentPage = self.currentCyclePage;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollRight ||
        self.configure.hy_scrollDirection == HyCycleViewScrollBottom) {
        currentPage = self.totalCycleCount - 1 - self.currentCyclePage;
    }
    return currentPage;
}

- (CGFloat)getScrollViewContentOffsetIndex {
    
    CGFloat contentOffset = self.scrollView.contentOffset.x;
    CGFloat contentMargin = self.scrollView.width;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollTop ||
        self.configure.hy_scrollDirection == HyCycleViewScrollBottom) {
        contentOffset = self.scrollView.contentOffset.y;
        contentMargin = self.scrollView.height;
    }
    return contentOffset / contentMargin;
}

- (NSInteger)handleIndex:(NSInteger)index {
    
    NSInteger dataIndex = index;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollLeft ||
        self.configure.hy_scrollDirection == HyCycleViewScrollTop) {
        if (dataIndex > self.totalCycleCount - 1) {
            dataIndex = 0;
        }
    } else {
        dataIndex = self.totalCycleCount - 1 - index;
        if (dataIndex < 0) {
            dataIndex = self.totalCycleCount - 1;
        }
    }
    return dataIndex;
}

#pragma mark — response methods
- (void)next {
    [self scrollToNextPageWithAnimated:YES
                           handleTimer:NO];
}

- (void)tap:(UITapGestureRecognizer *)ges {
    
    NSInteger index = ges.view.tag;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollRight ||
        self.configure.hy_scrollDirection == HyCycleViewScrollBottom) {
        index = self.totalCycleCount - 1 - index;
    }
    !self.configure.hy_clickAction ?: self.configure.hy_clickAction(self, index);
}

- (void)startTimer {
    [self stopTimer];
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    
    dispatch_source_set_timer(self.timer,
                              dispatch_time(DISPATCH_TIME_NOW, self.configure.hy_timeInterval * NSEC_PER_SEC),
                              self.configure.hy_timeInterval * NSEC_PER_SEC,
                              0 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer,
                                      ^{
                                          @autoreleasepool{
                                              [weakSelf next];
                                          }
                                      });
    dispatch_resume(self.timer);
}

- (void)stopTimer {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = NULL;
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        
    NSInteger page = 0;
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIView *contentView = self.scrollView.subviews[i];
        CGFloat distance = 0;
        switch (self.configure.hy_scrollDirection) {
            case HyCycleViewScrollLeft: {
                distance = ABS(contentView.left - scrollView.contentOffset.x);
            }break;
            case HyCycleViewScrollRight: {
                distance = ABS(scrollView.contentOffset.x - contentView.left);
            }break;
            case HyCycleViewScrollTop: {
                distance = ABS(contentView.top - scrollView.contentOffset.y);
            }break;
            case HyCycleViewScrollBottom: {
                distance = ABS(scrollView.contentOffset.y - contentView.top);
            }break;
            default:
            break;
        }
        if (distance < minDistance) {
            minDistance = distance;
            page = contentView.tag;
        }
    }
    self.roundingCyclePage = page;
    
    CGFloat index = [self getScrollViewContentOffsetIndex];
    if (index != 1) {
        
        if ([self isNotCycleLoop]) {
            [self addViewWithContentViewIndex:1
                                    pageIndex:self.scrollView.subviews[1].tag
                         isResetContentOffset:NO];
        }
        
        if (index < 1) {
            [self addViewWithContentViewIndex:0
                                    pageIndex:self.scrollView.subviews.firstObject.tag
                         isResetContentOffset:NO];
        } else if (index > 1) {
            [self addViewWithContentViewIndex:2
                                    pageIndex:self.scrollView.subviews.lastObject.tag
                         isResetContentOffset:NO];
        }
    }
    
    
    if (self.configure.hy_scrollProgress) {
        NSInteger fromPage;
        NSInteger toPage;
        CGFloat progress;
        
        if (index < 1) {
            
            NSInteger currentPage = self.currentCyclePage;
            if ([self isNotCycleLoop]) {
                currentPage = self.scrollView.subviews[1].tag;
            }
            
            if (index <= self.lastScrollProgress ) {
                fromPage = currentPage;
                if ([self isNotCycleLoop]) {
                    if (self.currentCyclePage == self.totalCycleCount - 1) {
                        fromPage = self.totalCycleCount - 1;
                    }
                }
                toPage = self.scrollView.subviews.firstObject.tag;
                progress = 1 - index;
                
            } else {
                if ([self isNotCycleLoop]) {
                    fromPage = 0;
                } else {
                    fromPage = self.scrollView.subviews.firstObject.tag;
                }
                toPage = currentPage;
                progress = index;
            }
            
        } else if (index > 1) {
            
            NSInteger currentPage = self.currentCyclePage;
            if ([self isNotCycleLoop]) {
                currentPage = self.scrollView.subviews[1].tag;
            }
            
            if (index >= self.lastScrollProgress ) {
                fromPage = currentPage;
                if ([self isNotCycleLoop]) {
                    if (self.currentCyclePage == 0) {
                        fromPage = 0;
                    }
                }
                toPage = self.scrollView.subviews.lastObject.tag;
                progress = index - 1;
            } else {
                if ([self isNotCycleLoop]) {
                    fromPage = self.totalCycleCount - 1;
                } else {
                   fromPage = self.scrollView.subviews.lastObject.tag;
                }
                toPage = currentPage;
                progress = 2 - index;
            }
            
        } else {
            
            progress = 1;
            fromPage = self.lastFromIndex;
            toPage = self.lastToIndex;
        }
        
        self.configure.hy_scrollProgress(self, [self handleIndex:fromPage], [self handleIndex:toPage], progress);
        
        self.lastScrollProgress = index;
        self.lastFromIndex = fromPage;
        self.lastToIndex = toPage;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.totalCycleCount > 1 &&
        self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
         [self stopTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.totalCycleCount > 1 &&
        self.configure.hy_scrollStyle == HyCycleViewScrollAuto) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateContentOffsetAndContentView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateContentOffsetAndContentView];
}

#pragma mark — getters and setters
- (HyGestureScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[HyGestureScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (HyCycleViewConfigure *)configure {
    if (!_configure){
        _configure = [HyCycleViewConfigure defaultConfigure];
    }
    return _configure;
}

- (NSMutableArray *)addedCycleViews {
    if (!_addedCycleViews){
        _addedCycleViews = @[].mutableCopy;
        for (int i = 0; i < self.totalCycleCount; i++) {
            [_addedCycleViews addObject:@1];
        }
    }
    return _addedCycleViews;
}

- (void)setTotalCycleCount:(NSInteger)totalCycleCount {
    _totalCycleCount = totalCycleCount;
    [self.addedCycleViews removeAllObjects];
    for (int i = 0; i < self.totalCycleCount; i++) {
        [_addedCycleViews addObject:@1];
    }
}

- (void)setCurrentCyclePage:(NSInteger)currentCyclePage {
    
    if (currentCyclePage == _currentCyclePage) {
        return;
    }
    
    _currentCyclePage = currentCyclePage;
    
    NSInteger currentPage = currentCyclePage;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollRight ||
        self.configure.hy_scrollDirection == HyCycleViewScrollBottom) {
        currentPage = self.totalCycleCount - 1 - currentCyclePage;
    }
    
    !self.configure.hy_currentPageChange ?:
    self.configure.hy_currentPageChange(self, self.totalCycleCount, currentPage);
}

- (void)setRoundingCyclePage:(NSInteger)roundingCyclePage {
    
    if (roundingCyclePage == _roundingCyclePage) {
        return;
    }
    
    _roundingCyclePage = roundingCyclePage;
    
    NSInteger currentPage = roundingCyclePage;
    if (self.configure.hy_scrollDirection == HyCycleViewScrollRight ||
        self.configure.hy_scrollDirection == HyCycleViewScrollBottom) {
        currentPage = self.totalCycleCount - 1 - roundingCyclePage;
    }
    !self.configure.hy_roundingPageChange ?:
    self.configure.hy_roundingPageChange(self, self.totalCycleCount, currentPage);
}

- (void)dealloc {
    [self stopTimer];
}
@end


@implementation HyCycleViewConfigure

+ (instancetype)defaultConfigure {
    HyCycleViewConfigure *configure = [[self alloc] init];
    configure.timeInterval(2).isCycleLoop(YES).scrollStyle(HyCycleViewScrollAuto);
    return configure;
}

- (HyCycleViewConfigure *(^)(BOOL))isCycleLoop {
    return ^HyCycleViewConfigure *(BOOL cycleLoop) {
        self.hy_isCycleLoop = cycleLoop;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(NSInteger))totalPage {
    return ^HyCycleViewConfigure *(NSInteger page) {
        self.hy_totalPage = page;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(NSInteger))startPage {
    return ^HyCycleViewConfigure *(NSInteger page) {
        self.hy_startPage = page;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(NSTimeInterval))timeInterval {
    return ^HyCycleViewConfigure *(NSTimeInterval timeInt) {
        self.hy_timeInterval = timeInt;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(HyCycleViewScrollStyle))scrollStyle {
    return ^HyCycleViewConfigure *(HyCycleViewScrollStyle style) {
        self.hy_scrollStyle = style;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(HyCycleViewScrollLoadStyle))loadStyle {
    return ^HyCycleViewConfigure *(HyCycleViewScrollLoadStyle style) {
        self.hy_loadStyle = style;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(HyCycleViewScrollDirection))scrollDirection {
    return ^HyCycleViewConfigure *(HyCycleViewScrollDirection direction) {
        self.hy_scrollDirection = direction;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(NSArray<Class> *))cycleClasses {
    return ^HyCycleViewConfigure *(NSArray<Class> *array) {
        self.hy_cycleClasses = array;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(Class (^)(HyCycleView *, NSInteger)))cycleClass {
    return ^HyCycleViewConfigure *(Class(^blcok)(HyCycleView *, NSInteger)) {
        self.hy_cycleClass = [blcok copy];
        return self;
    };
}

- (HyCycleViewConfigure *(^)(NSArray *))cycleInstances {
    return ^HyCycleViewConfigure *(NSArray *array) {
        self.hy_cycleInstances = array;
        return self;
    };
}

- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *, NSInteger)))clickAction {
    return ^HyCycleViewConfigure *(void(^blcok)(HyCycleView *, NSInteger)) {
        self.hy_clickAction = [blcok copy];
        return self;
    };
}

- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *,
                                     id,
                                     NSInteger,
                                     BOOL)))viewWillAppear {
    
    return ^HyCycleViewConfigure *(void(^blcok)(HyCycleView *,
                                                UIView *,
                                                NSInteger,
                                                BOOL)) {
        self.hy_viewWillAppear = [blcok copy];
        return self;
    };
}

- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *,
                                     NSInteger,
                                     NSInteger)))currentPageChange {
    
    return ^HyCycleViewConfigure *(void(^blcok)(HyCycleView *,
                                                NSInteger,
                                                NSInteger)) {
        self.hy_currentPageChange = [blcok copy];
        return self;
    };
}

- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *,
                                     NSInteger,
                                     NSInteger)))roundingPageChange {
    
    return ^HyCycleViewConfigure *(void(^blcok)(HyCycleView *,
                                                NSInteger,
                                                NSInteger)) {
        self.hy_roundingPageChange = [blcok copy];
        return self;
    };
}

- (HyCycleViewConfigure *(^)(void(^)(HyCycleView *,
                                     NSInteger,
                                     NSInteger,
                                     CGFloat)))scrollProgress {
    
    return ^HyCycleViewConfigure *(void(^blcok)(HyCycleView *,
                                                NSInteger,
                                                NSInteger,
                                                CGFloat)) {
        self.hy_scrollProgress = [blcok copy];
        return self;
    };
}

- (void)setHy_totalPage:(NSInteger)hy_totalPage {
    _hy_totalPage = hy_totalPage;
    
    if (self.cycleView) {
        [self.cycleView updateTotalPage];
    }
}

- (void)sethy_startPage:(NSInteger)hy_startPage {
    _hy_startPage = hy_startPage;
    
    if (self.cycleView) {
        [self.cycleView updateStartPage];
    }
}

- (void)setHy_timeInterval:(NSTimeInterval)hy_timeInterval {
    _hy_timeInterval = hy_timeInterval;
    
    if (self.cycleView) {
        [self.cycleView updateTimeInterval];
    }
}

- (void)setHy_cycleClasses:(NSArray<Class> *)hy_cycleClasses {
    _hy_cycleClasses = hy_cycleClasses;
    
    if (self.cycleView) {
        [self.cycleView updateCycleClasses];
    }
}

- (void)setHy_cycleClass:(Class (^)(HyCycleView *, NSInteger))hy_cycleClass {
    _hy_cycleClass = [hy_cycleClass copy];
    
    if (self.cycleView) {
        [self.cycleView updateCycleClass];
    }
}

- (void)setHy_cycleInstances:(NSArray *)hy_cycleInstances {
    _hy_cycleInstances = hy_cycleInstances;
    
    if (self.cycleView) {
        [self.cycleView updateCycleInstances];
    }
}

- (void)setHy_scrollStyle:(HyCycleViewScrollStyle)hy_scrollStyle {
    _hy_scrollStyle = hy_scrollStyle;
    
    if (self.cycleView) {
        [self.cycleView updateScrollStyle];
    }
}

- (void)setHy_scrollDirection:(HyCycleViewScrollDirection)hy_scrollDirection {
    _hy_scrollDirection = hy_scrollDirection;
    
    if (self.cycleView) {
        [self.cycleView updateScrollDirection];
    }
}

- (NSInteger)currentPage {
    return [self.cycleView getCurrentPage];
}

@end
