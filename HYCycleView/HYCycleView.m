//
//  HYCycleView.m
//  ScrollView
//
//  Created by jsb06 on 16/5/3.
//  Copyright © 2016年 jsb06. All rights reserved.
//

#import "HYCycleView.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"

typedef enum {
    HYCycleViewContentViewClassType,
    HYCycleViewContentViewNibType
} HYCycleViewContentViewType;

@interface HYCycleView () <UIScrollViewDelegate>
@property (weak, nonatomic) NSTimer *timer;
@property (nonatomic, strong) Class contentViewClass;
@property (nonatomic, copy) NSString *ContentViewNibName;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign, getter=isLoadLoaclImage) BOOL loadLoaclImage;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, copy) NSString *placeholderImage;
@property (nonatomic, strong) NSArray *dateArray;
@property (nonatomic, assign) HYCycleViewTimerStyle  timerStyle;
@property (nonatomic, assign) HYCycleViewContentViewType  contentViewType;
@property (nonatomic, assign) HYCycleViewScrollDirection  lastScrollDirection;
@end

#define HYMsgSend(...) ((void (*)(void *, SEL, id))objc_msgSend)(__VA_ARGS__)
#define HYMsgTarget(target) (__bridge void *)(target)
static int const ContentViewCount = 3;

@implementation HYCycleView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    [self  insertSubview:pageControl atIndex:100];
    self.pageControl = pageControl;
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
}


+ (instancetype)CycleViewWithFrame:(CGRect)frame localImageNameArray:(NSArray *)localImageNameArray timerStyle:(HYCycleViewTimerStyle)timerStlye
{
    HYCycleView *cycleView = [[self alloc] initWithFrame:frame];
    cycleView.contentViewClass = [UIImageView class];
    cycleView.contentViewType = HYCycleViewContentViewClassType;
    cycleView.timerStyle = timerStlye;
    cycleView.loadLoaclImage = YES;
    [cycleView createCycleViewOfContentViewType:cycleView.contentViewType contentViewClass:cycleView.contentViewClass contentViewNibName:cycleView.ContentViewNibName ContentViewModels:localImageNameArray timerStyle:timerStlye resetModel:NO];
    return cycleView;
}

+ (instancetype)CycleViewWithFrame:(CGRect)frame NetImageUrlArray:(NSArray *)NetImageUrlArray placeholderImage:(NSString *)placeholderImage timerStyle:(HYCycleViewTimerStyle)timerStlye
{
    HYCycleView *cycleView = [[self alloc] initWithFrame:frame];
    cycleView.contentViewClass = [UIImageView class];
    cycleView.timerStyle = timerStlye;
    cycleView.contentViewType = HYCycleViewContentViewClassType;
    cycleView.loadLoaclImage = NO;
    cycleView.placeholderImage = placeholderImage;
    [cycleView createCycleViewOfContentViewType:cycleView.contentViewType contentViewClass:cycleView.contentViewClass contentViewNibName:cycleView.ContentViewNibName ContentViewModels:NetImageUrlArray timerStyle:timerStlye resetModel:NO];
    return cycleView;
}

+ (instancetype)CycleViewWithFrame:(CGRect)frame contentViewClass:(nullable Class)contentViewClass models:(NSArray *)models timerStyle:(HYCycleViewTimerStyle)timerStlye
{
    HYCycleView *cycleView = [[self alloc] initWithFrame:frame];
    cycleView.contentViewClass = contentViewClass;
    cycleView.contentViewType = HYCycleViewContentViewClassType;
    cycleView.timerStyle = timerStlye;
    [cycleView createCycleViewOfContentViewType:cycleView.contentViewType contentViewClass:cycleView.contentViewClass contentViewNibName:cycleView.ContentViewNibName ContentViewModels:models timerStyle:timerStlye resetModel:NO];
    return cycleView;
}

+ (instancetype)CycleViewWithFrame:(CGRect)frame contentViewNibName:(NSString *)nibName models:(NSArray *)models timerStyle:(HYCycleViewTimerStyle)timerStlye
{
    HYCycleView *cycleView = [[self alloc] initWithFrame:frame];
    cycleView.contentViewClass = NSClassFromString(nibName);
    cycleView.contentViewType = HYCycleViewContentViewNibType;
    cycleView.ContentViewNibName = nibName;
    cycleView.timerStyle = timerStlye;
    [cycleView createCycleViewOfContentViewType:cycleView.contentViewType contentViewClass:cycleView.contentViewClass contentViewNibName:cycleView.ContentViewNibName ContentViewModels:models timerStyle:timerStlye resetModel:NO];
    return cycleView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self setScrollViewContentSize];
    if (self.scrollView.subviews.count) {
        for (int i = 0; i<ContentViewCount; i++) {
            [self setFrameOfContentViewIndex:i];
        }
    }
    
    CGFloat pageW = 80;
    CGFloat pageH = 20;
    CGFloat pageX = (self.scrollView.frame.size.width - pageW) / 2;
    CGFloat pageY = self.scrollView.frame.size.height - pageH;
    self.pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
    
    [self updateContent];
}

- (void)setScrollViewContentSize
{
    switch (self.scrollDirection) {
        case HYCycleViewScrollLeft :
            self.pageControl.currentPage = 0;
            self.scrollView.contentSize = CGSizeMake(ContentViewCount * self.bounds.size.width, 0);
            break;
        case HYCycleViewScrollRight :
            self.pageControl.currentPage = self.dateArray.count;
            self.scrollView.contentSize = CGSizeMake(ContentViewCount * self.bounds.size.width, 0);
            break;
        case HYCycleViewScrollTop :
            self.pageControl.currentPage = 0;
            self.scrollView.contentSize = CGSizeMake(0, ContentViewCount * self.bounds.size.height);
            break;
        case HYCycleViewScrollBottom :
            self.pageControl.currentPage = self.dateArray.count;
            self.scrollView.contentSize = CGSizeMake(0, ContentViewCount * self.bounds.size.height);
            break;
        default:
            break;
    }
}

- (void)ResetScrollViewContentSize
{
    switch (self.scrollDirection) {
        case HYCycleViewScrollLeft :
            self.scrollView.contentSize = CGSizeMake(ContentViewCount * self.bounds.size.width, 0);
            break;
        case HYCycleViewScrollRight :
            self.scrollView.contentSize = CGSizeMake(ContentViewCount * self.bounds.size.width, 0);
            break;
        case HYCycleViewScrollTop :
            self.scrollView.contentSize = CGSizeMake(0, ContentViewCount * self.bounds.size.height);
            break;
        case HYCycleViewScrollBottom :
            self.scrollView.contentSize = CGSizeMake(0, ContentViewCount * self.bounds.size.height);
            break;
        default:
            break;
    }
}


- (void)setFrameOfContentViewIndex:(NSInteger)index
{
    UIView *contentView = self.scrollView.subviews[index];
    switch (self.scrollDirection) {
        case HYCycleViewScrollLeft:
        case HYCycleViewScrollRight:
            contentView.frame = CGRectMake(index * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            break;
        case HYCycleViewScrollTop:
        case HYCycleViewScrollBottom:
            contentView.frame = CGRectMake(0, index * self.scrollView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            break;
            
        default:
            break;
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = 0;
    CGFloat minDistance = MAXFLOAT;
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIView *contentView = self.scrollView.subviews[i];
        CGFloat distance = 0;
        switch (self.scrollDirection) {
            case HYCycleViewScrollLeft:
                distance = ABS(contentView.frame.origin.x - scrollView.contentOffset.x);
                break;
            case HYCycleViewScrollRight :
                distance = ABS(scrollView.contentOffset.x - contentView.frame.origin.x );
                break;
            case HYCycleViewScrollTop :
                distance = ABS(contentView.frame.origin.y - scrollView.contentOffset.y);
                break;
            case HYCycleViewScrollBottom :
                distance = ABS(scrollView.contentOffset.y - contentView.frame.origin.y );
                break;
                
            default:
                break;
        }
        
        if (distance < minDistance) {
            minDistance = distance;
            page = contentView.tag;
        }
    }
    
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.pageControl.numberOfPages >1 && self.timerStyle == HYCycleViewTimerStart) {
        [self stopTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.pageControl.numberOfPages >1 && self.timerStyle == HYCycleViewTimerStart) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContent];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateContent];
}

#pragma mark - 更新
- (void)updateContent
{
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIView *contentView = self.scrollView.subviews[i];
        NSInteger index = self.pageControl.currentPage;
        if (i == 0) {
            index--;
        } else if (i == 2) {
            index++;
        }
        if (index < 0) {
            index = self.pageControl.numberOfPages - 1;
        } else if (index >= self.pageControl.numberOfPages) {
            index = 0;
        }
        
        contentView.tag = index;
        if (self.scrollDirection == HYCycleViewScrollLeft || self.scrollDirection == HYCycleViewScrollTop) {
            if (index == 0) {
                self.index = self.pageControl.numberOfPages - 1;
            } else {
                self.index = index - 1;
            }
        }
        
        if (self.scrollDirection == HYCycleViewScrollRight || self.scrollDirection == HYCycleViewScrollBottom) {
            index = self.pageControl.numberOfPages - 1 -  index;
            if (index == self.pageControl.numberOfPages - 1) {
                self.index = 0;
            } else {
                self.index = index + 1;
            }
        }
        if (!self.dateArray.count) {
            return;
        }
        
        if ([NSStringFromClass(self.contentViewClass) isEqualToString:@"UIImageView"]) { // imageView
            UIImageView *imageView = (UIImageView *)contentView;
            if (self.isLoadLoaclImage) {
                imageView.image = [UIImage imageNamed:self.dateArray[index]];
            } else {
                NSString *url = [NSString stringWithFormat:@"%@", self.dateArray[index]];
                [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:self.placeholderImage]];
            }
        } else { // 自定义控件
            
            NSString *ModelMethodName = @"setModel:";// 默认set方法
            unsigned int countM = 0;
            Method *methodsM = class_copyMethodList(self.contentViewClass, &countM);
            for (int i = 0; i<countM; i++) {
                Method methodM = methodsM[i];
                SEL methodMS = method_getName(methodM);
                NSString *name = NSStringFromSelector(methodMS);
                
                if ([name isEqualToString:@"SetupContentModelName"]) {
                    if ([contentView respondsToSelector:methodMS]) {
                        if ([contentView respondsToSelector:methodMS]) {
                            NSString *resetModelName = ((NSString * (*)(id, SEL))objc_msgSend)((id)contentView, methodMS);
                            if (resetModelName.length) {
                                NSString *firstStr = [resetModelName substringToIndex:1];
                                NSString *finalStr = [resetModelName substringFromIndex:1];
                                firstStr = [firstStr uppercaseString];
                                resetModelName = [NSString stringWithFormat:@"set%@%@:", firstStr, finalStr]; // 合成set方法名
                                ModelMethodName = resetModelName;
                            }
                        }
                    }
                }
            }
            free(methodsM);
            
            unsigned int countN = 0;
            Method *methodsN = class_copyMethodList(self.contentViewClass, &countN);
            for (int i = 0; i<countN; i++) {
                Method methodN = methodsN[i];
                SEL methodNS = method_getName(methodN);
                NSString *name = NSStringFromSelector(methodNS);
                if ([name isEqualToString:ModelMethodName]) {
                    if ([contentView respondsToSelector:methodNS]) {
                        HYMsgSend(HYMsgTarget(contentView), methodNS, self.dateArray[index]);
                        // ((void (*)(id, SEL, id))objc_msgSend)((id)contentView, methodN, self.models[index]);
                    }
                }
            }
            free(methodsN);
        }
    }
    [self updateScrollViewContentOffset];
}

- (void)updateScrollViewContentOffset
{
    switch (self.scrollDirection) {
        case HYCycleViewScrollLeft:
        case HYCycleViewScrollRight:
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
            break;
        case HYCycleViewScrollTop:
        case HYCycleViewScrollBottom:
            self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
            break;
        default:
            break;
    }
}

#pragma mark - 定时器
- (void)startTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(next) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [self stopTimer];
}

- (void)next
{
    [self setupScrollViewContentOffset];
}

- (void)setupScrollViewContentOffset
{
    switch (self.scrollDirection) {
        case HYCycleViewScrollLeft:
            [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.frame.size.width, 0) animated:YES];
            break;
        case HYCycleViewScrollRight:
            [self.scrollView setContentOffset:CGPointMake( 0, 0) animated:YES];
            break;
        case HYCycleViewScrollTop:
            [self.scrollView setContentOffset:CGPointMake(0, 2 * self.scrollView.frame.size.height) animated:YES];
            break;
        case HYCycleViewScrollBottom:
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)tap
{
    if (self.dateArray.count) {
        if ([self.delegate respondsToSelector:@selector(cycleView:didSelectAtIndex:)]) {
            [self.delegate cycleView:self didSelectAtIndex:self.index];
        }
    }
}

- (void)setModels:(NSMutableArray *)models
{
    _models = models;
    [self stopTimer];
    [self createCycleViewOfContentViewType:self.contentViewType contentViewClass:self.contentViewClass contentViewNibName:self.ContentViewNibName ContentViewModels:models timerStyle:self.timerStyle resetModel:YES];
    
}

- (void)setLocalImageNameArray:(NSMutableArray *)localImageNameArray
{
    _localImageNameArray = localImageNameArray;
    [self stopTimer];
    [self createCycleViewOfContentViewType:self.contentViewType contentViewClass:self.contentViewClass contentViewNibName:self.ContentViewNibName ContentViewModels:localImageNameArray timerStyle:self.timerStyle resetModel:YES];
    
}

- (void)setNetImageUrlArray:(NSMutableArray *)NetImageUrlArray
{
    _NetImageUrlArray = NetImageUrlArray;
    [self stopTimer];
    [self createCycleViewOfContentViewType:self.contentViewType contentViewClass:self.contentViewClass contentViewNibName:self.ContentViewNibName ContentViewModels:NetImageUrlArray timerStyle:self.timerStyle resetModel:YES];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    if (timeInterval <= 0) {
        timeInterval = 2;
    }
    _timeInterval = timeInterval;
    if (self.timerStyle == HYCycleViewTimerStart) {
        [self stopTimer];
        [self startTimer];
    }
}

- (void)setImageViewContentMode:(UIViewContentMode)imageViewContentMode
{
    _imageViewContentMode = imageViewContentMode;
    if ([NSStringFromClass(self.contentViewClass) isEqualToString:@"UIImageView"]) {
        for (UIImageView *imageView in self.scrollView.subviews) {
            imageView.contentMode = imageViewContentMode;
            imageView.clipsToBounds = YES;
        }
    }
}

- (void)setScrollDirection:(HYCycleViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    [self stopTimer];
    [self createCycleViewOfContentViewType:self.contentViewType contentViewClass:self.contentViewClass contentViewNibName:self.ContentViewNibName ContentViewModels:self.dateArray timerStyle:self.timerStyle resetModel:YES];
    self.lastScrollDirection = scrollDirection;
}

- (void)createCycleViewOfContentViewType:(HYCycleViewContentViewType)contentViewType contentViewClass:(nullable Class)contentViewClass contentViewNibName:(NSString *)contentViewNibName ContentViewModels:(NSArray *)ContentViewModels timerStyle:(HYCycleViewTimerStyle)timerStlye resetModel:(BOOL)resetModel
{
    self.dateArray = ContentViewModels;
    
    if (!resetModel) {
        for (int i = 0; i<ContentViewCount; i++) {
            UIView *contentView;
            if (contentViewType == HYCycleViewContentViewClassType) {
                contentView = [[contentViewClass alloc] init];
            } else {
                contentView = [[[NSBundle mainBundle] loadNibNamed:contentViewNibName owner:nil options:nil] lastObject];
            }
            contentView.userInteractionEnabled = YES;
            [self.scrollView addSubview:contentView];
            [self setFrameOfContentViewIndex:i];
        }
        [self setScrollViewContentSize];
    }
    
    if (self.lastScrollDirection != self.scrollDirection ) {
        if (self.scrollView.subviews.count) {
            for (int i = 0; i<ContentViewCount; i++) {
                [self setFrameOfContentViewIndex:i];
                [self resetContentViewTagIndex:i]; // 改变方向从第一张开始
            }
            
        }
        [self setScrollViewContentSize];
    }
    
    if (ContentViewModels.count == 0) {
        for (UIView *view in  self.scrollView.subviews) {
            view.hidden = YES;
        }
        self.pageControl.hidden = YES;
        return;
    } else {
        for (UIView *view in  self.scrollView.subviews) {
            view.hidden = NO;
        }
        self.pageControl.hidden = NO;
    }
    
    self.pageControl.numberOfPages = ContentViewModels.count;
    [self updateContent];
    
    if (ContentViewModels.count == 1) {
        [self stopTimer];
        self.scrollView.scrollEnabled = NO;
        self.pageControl.hidden = YES;
    } else {
        self.scrollView.scrollEnabled = YES;
        self.pageControl.hidden = NO;
        if (timerStlye == HYCycleViewTimerStart) {
            [self startTimer];
        } else {
            [self stopTimer];
        }
    }
}


- (void)resetContentViewTagIndex:(NSInteger)index
{
    UIView *contentView = self.scrollView.subviews[index];
    switch (self.scrollDirection) {
        case HYCycleViewScrollLeft :
        case HYCycleViewScrollTop :
            contentView.tag = 0;
            break;
        case HYCycleViewScrollRight :
        case HYCycleViewScrollBottom :
            contentView.tag = self.dateArray.count - 1;
            break;
        default:
            break;
    }
}

@end
