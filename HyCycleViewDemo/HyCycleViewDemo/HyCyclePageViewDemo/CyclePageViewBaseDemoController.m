//
//  CyclePageViewBaseDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewBaseDemoController.h"
#import <MJRefresh/MJRefresh.h>


@interface CyclePageViewBaseDemoController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) HyCycleView *cycleView;
@property (nonatomic,strong) HySegmentView *segmentView;
@property (nonatomic,strong) HyCyclePageView *cyclePageView;
@property (nonatomic,strong) NSArray<NSString *> *titleArray;
@property (nonatomic,strong) NSArray<UIColor *> *colorArray;
@end


@implementation CyclePageViewBaseDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    self.titleArray = @[@"NBA", @"国际足球", @"中国篮球", @"跑步",@"欧洲杯", @"欧冠" ,@"英超", @"西甲", @"意甲"];
  
    [self.view addSubview:self.scrollView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.cyclePageView.heightValue(self.scrollView.height - self.scrollView.adjustedContentInset.top);
}

- (UIView *)hoverView {
    return self.segmentView;
}

- (UIView *)headerView {
    return self.cycleView;
}

- (void(^)(HyCyclePageViewConfigure *configure))configPageView {
    return nil;
}

- (void(^)(HySegmentViewConfigure *configure))configSegmentView {
    return nil;
}

- (UITableView *)creatTableViewWithPageNumber:(NSInteger)pageNumber {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView registerClass:UITableViewCell.class
      forCellReuseIdentifier:@"UITableViewCell"];
    tableView.tag = pageNumber;
    tableView.rowHeight = 50;
    tableView.sectionHeaderHeight = 0.01;
    tableView.sectionFooterHeight = 0.01;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    if (self.gestureStyle == HyCyclePageViewGestureStyleMultiple) {
        tableView.backgroundColor = UIColor.grayColor;
    }
    return tableView;
}

#pragma mark — UITableViewDataSource , UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = UIColor.grayColor;
    NSString *string = self.titleArray[tableView.tag];
    cell.textLabel.text = [NSString stringWithFormat:@"%@_%tu", string, indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark — getters and setters
- (UIScrollView *)scrollView {
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_scrollView addSubview:self.cyclePageView];
    }
    return _scrollView;
}

- (HyCyclePageView *)cyclePageView {
    if (!_cyclePageView){
         __weak typeof(self) weakSelf = self;
        _cyclePageView = [HyCyclePageView cyclePageViewWithFrame:_scrollView.bounds
                                                  configureBlock:^(HyCyclePageViewConfigure * _Nonnull configure) {
                                                      
                                                      configure
                                                      .totalPage(weakSelf.titleArray.count)
                                                      .gestureStyle(weakSelf.gestureStyle)
                                                      .cyclePageInstance(^id(HyCyclePageView *pageView, NSInteger currentIndex){
                                                          return [weakSelf creatTableViewWithPageNumber:currentIndex];
                                                      })
                                                      .headerView(weakSelf.headerView)
                                                      .hoverView(weakSelf.hoverView)
                                                      .horizontalScroll(^(HyCyclePageView *cyclePageView,
                                                                          NSInteger fromPage,
                                                                          NSInteger toPage,
                                                                          CGFloat progress) {
                                                          [weakSelf.segmentView clickItemFromIndex:fromPage
                                                                                           toIndex:toPage
                                                                                          progress:progress];
                                                      });
                                                      !weakSelf.configPageView ?: weakSelf.configPageView(configure);
                                                  }];
    }
    return _cyclePageView;
}

- (HySegmentView *)segmentView {
    if (!_segmentView){
        
        __weak typeof(self) weakSelf = self;

        _segmentView =
        [HySegmentView segmentViewWithFrame:CGRectMake(0, 0, self.view.width, 40)
                             configureBlock:^(HySegmentViewConfigure * _Nonnull configure) {
            
            configure
            .numberOfItems(weakSelf.titleArray.count)
            .itemMargin(25)
            .viewForItemAtIndex(^UIView *(UIView *currentView,
                                          NSInteger currentIndex,
                                          CGFloat progress,
                                          HySegmentViewItemPosition position,
                                          NSArray<UIView *> *animationViews){

                UILabel *label = (UILabel *)currentView;
                if (!label) {
                    label = [UILabel new];
                    label.text = weakSelf.titleArray[currentIndex];
                    label.textAlignment = NSTextAlignmentCenter;
                    [label sizeToFit];
                }
                if (progress == 0 || progress == 1) {
                    label.textColor =  progress == 0 ? UIColor.darkTextColor : UIColor.redColor;
                }
                return label;
            })
             .animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
                 
                 NSArray<UIView *> *array = currentAnimations;
                 if (!array.count) {
                     UIView *line = [UIView new];
                     line.backgroundColor = UIColor.redColor;
                     line.layer.cornerRadius = 1.5;
                     line.heightValue(3).bottomValue(40);
                     array = @[line];
                 }
                 
                 CGFloat margin = ABS(toCell.centerX - fromCell.centerX);
                 CGFloat currentProgress = progress <= 0.5 ? progress : (1 - progress);
                 CGFloat width = 15;
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
             })
            .clickItemAtIndex(^BOOL(NSInteger currentIndex, BOOL isRepeat){
                
                if (!isRepeat) {
                    [weakSelf.cyclePageView scrollToPage:currentIndex animated:YES];
                }
                return NO;
            });
            !weakSelf.configSegmentView ?: weakSelf.configSegmentView(configure);
        }];
    }
    return _segmentView;
}

- (HyCycleView *)cycleView {
    if (!_cycleView){
        
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
        
        NSArray *imageArray = @[@"one",@"two",@"three",@"four"];
        _cycleView =
        [HyCycleView cycleViewWithFrame:CGRectMake(0, 0, self.view.width, 250)
                         configureBlock:^(HyCycleViewConfigure *configure) {
            
                            configure
                            .cycleClasses(@[UIImageView.class])
                            .totalPage(imageArray.count)
                            .scrollStyle(HyCycleViewScrollStatic)
                            .viewWillAppear(^(HyCycleView *cycleView,
                                              UIImageView *imageView,
                                              NSInteger index,
                                              BOOL isfirstLoad) {
                                if (isfirstLoad) {
                                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                                    imageView.image = [UIImage imageNamed:imageArray[index]];
                                }
                            })
                            .roundingPageChange(^(HyCycleView *cycleView, NSInteger totalPage, NSInteger currentPage){
                                
                                if (!pageControl.superview) {
                                    [cycleView addSubview:pageControl];
                                }
                                CGFloat pageW = 15 * totalPage;
                                CGFloat pageH = 20;
                                CGFloat pageX = (cycleView.frame.size.width - pageW) / 2;
                                CGFloat pageY = cycleView.frame.size.height - pageH;
                                pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
                                pageControl.numberOfPages = totalPage;
                                pageControl.currentPage = currentPage;
                            });
        }];
    }
    return _cycleView;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
