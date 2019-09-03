//
//  CyclePageViewTaoBaoDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewTaoBaoDemoController.h"
#import "CyclePageViewTaoBaoDemoCell.h"


@interface CyclePageViewTaoBaoDemoController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic,strong) NSMutableArray<UIView *> *lines;
@property (nonatomic,strong) NSMutableArray<UILabel *> *subTitleLabelArray;
@property (nonatomic,strong) UIView *animationLine;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) HySegmentView *segmentView;
@end


@implementation CyclePageViewTaoBaoDemoController
@dynamic segmentView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentView.height = 60;
    self.segmentView.backgroundColor = UIColor.clearColor;
}

- (NSArray<NSString *> *)titleArray {
    return @[@"全部", @"直播", @"便宜好货", @"全球", @"生活", @"时尚", @"母婴"];
}

- (NSArray<NSString *> *)subTitleArray {
    return @[@"猜你喜欢", @"网红推荐", @"低价抢购", @"进口好货", @"享受生活", @"时尚好货", @"母婴大赏"];
}

- (UIView *)headerView {
    
    UIView *view = [[UIView alloc] init];
    
    UIImageView *imageViewOne = [[UIImageView alloc] init];
    imageViewOne.image = [UIImage imageNamed:@"taobao_one"];
    imageViewOne.widthValue(self.view.width)
    .heightValue(imageViewOne.image.size.height / imageViewOne.image.size.width * self.view.width);
    [view addSubview:imageViewOne];
    
    UIImageView *imageViewTwo = [[UIImageView alloc] init];
    imageViewTwo.image = [UIImage imageNamed:@"taobao_two"];
    imageViewTwo.widthValue(self.view.width)
    .heightValue(imageViewTwo.image.size.height / imageViewTwo.image.size.width * self.view.width)
    .topValue(imageViewOne.height);
    [view addSubview:imageViewTwo];
    
    view.size = CGSizeMake(self.view.width, imageViewTwo.bottom);
    
    return view;
}

- (void (^)(HyCyclePageViewConfigure * _Nonnull))configPageView {
    __weak typeof(self) weakSelf = self;
    return ^(HyCyclePageViewConfigure * _Nonnull configure){
        
        configure
        .cyclePageInstance(^id(HyCyclePageView *pageView, NSInteger currentIndex){
            return weakSelf.collectionView;
        })
        .verticalScroll(^(HyCyclePageView * cyclePageView,
                          CGFloat offsetY,
                          NSInteger currentPage) {
            
            CGFloat progress = (offsetY - weakSelf.headerView.height) / 18;            
            if (progress < 0) {progress = 0;}
            if (progress > 1) {progress = 1;}
            if (weakSelf.animationLine.alpha == 1.0 && progress > 0 && progress < 1) {
                return ;
            }
            
            weakSelf.animationLine.alpha = progress;
            weakSelf.animationLine.bottom = 50 - 8 * progress;
            [weakSelf.subTitleLabelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.alpha = 1 - progress;
            }];
            [weakSelf.lines enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.height = 30 - 10 * progress;
                obj.top = 5 - 3 * progress;
            }];
            
            weakSelf.backgroundView.height = weakSelf.segmentView.height - 18 * progress;
            weakSelf.backgroundView.backgroundColor =
            progress == 1 ? UIColor.whiteColor :
            [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1];
        });
    };
}

- (void (^)(HySegmentViewConfigure * _Nonnull))configSegmentView {
    __weak typeof(self) weakSelf = self;
    return ^(HySegmentViewConfigure * _Nonnull configure) {
        
        configure
        .itemMargin(0)
        .inset(UIEdgeInsetsMake(0, 10, 0, 10))
        .viewForItemAtIndex(^UIView *(UIView *currentView,
                                      NSInteger currentIndex,
                                      CGFloat progress,
                                      HySegmentViewItemPosition position,
                                      NSArray<UIView *> *animationViews) {

            UIView *view = currentView;
            if (!view) {
                view = [[UIView alloc] init];

                UILabel *titleLabel = [[UILabel alloc] init];
                titleLabel.font = [UIFont systemFontOfSize:16];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.text = weakSelf.titleArray[currentIndex];
                titleLabel.tag = 1;
                [titleLabel sizeToFit];
                [view addSubview:titleLabel];

                UILabel *subTitleLabel = [[UILabel alloc] init];
                subTitleLabel.textAlignment = NSTextAlignmentCenter;
                subTitleLabel.font = [UIFont systemFontOfSize:10];
                subTitleLabel.text = weakSelf.subTitleArray[currentIndex];
                subTitleLabel.tag = 2;
                [subTitleLabel sizeToFit];
                subTitleLabel.width += 10;
                subTitleLabel.height += 4;
                subTitleLabel.topValue(titleLabel.bottom + 2);
                [view addSubview:subTitleLabel];
                [weakSelf.subTitleLabelArray addObject:subTitleLabel];
                
                CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
                gradientLayer.frame = subTitleLabel.bounds;
                gradientLayer.cornerRadius = subTitleLabel.height / 2;
                gradientLayer.colors = @[(id)[UIColor colorWithRed:255 / 255.0 green:112 / 255.0 blue:0 / 255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:255 / 255.0 green:48 / 255.0 blue:0 / 255.0 alpha:1].CGColor];
                gradientLayer.locations = @[@0.25,@0.75];
                gradientLayer.startPoint = CGPointMake(0, .5);
                gradientLayer.endPoint = CGPointMake(1, .5);
                [subTitleLabel.layer addSublayer:gradientLayer];
                gradientLayer.hidden = YES;

                view
                .heightValue(subTitleLabel.bottom)
                .widthValue(MAX(titleLabel.width, subTitleLabel.width) + 15);

                titleLabel.centerXValue(view.width / 2);
                subTitleLabel.centerXIsEqualTo(titleLabel);

                if (currentIndex != weakSelf.subTitleArray.count - 1) {
                    UIView *line = [[UIView alloc] init];
                    line.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1];
                    line.tag = 3;
                    [view addSubview:line];
                    line
                    .widthValue(.5)
                    .heightValue(30)
                    .rightValue(view.width)
                    .topValue(5);
                    [weakSelf.lines addObject:line];
                }
            }
            
            if (progress == 0 || progress == 1) {
                
                UILabel *titleLabel =  ((UILabel *)[view viewWithTag:1]);
                UILabel *subTitleLabel =  ((UILabel *)[view viewWithTag:2]);
                __block CAGradientLayer *gradientLayer;
                [subTitleLabel.layer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:CAGradientLayer.class]) {
                        gradientLayer = obj;
                        *stop = YES;
                    };
                }];
                
                titleLabel.textColor = progress ? [UIColor colorWithRed:255 / 255.0 green:48 / 255.0 blue:0 / 255.0 alpha:1] : UIColor.darkTextColor;
                subTitleLabel.textColor = progress ? UIColor.whiteColor : UIColor.grayColor;
                gradientLayer.hidden = !progress;
            }
        
            return view;
            
        }).animationViews(^NSArray<UIView *> *(NSArray<UIView *> *currentAnimations, UICollectionViewCell *fromCell, UICollectionViewCell *toCell, NSInteger fromIndex, NSInteger toIndex, CGFloat progress){
            
            NSArray<UIView *> *array = currentAnimations;
            if (!array.count) {
                UIView *line = [UIView new];
                line.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:48 / 255.0 blue:0 / 255.0 alpha:1];
                line.layer.cornerRadius = 1.5;
                line.heightValue(3).bottomValue(50).widthValue(40);
                weakSelf.animationLine = line;
                
                UIView *backgroundView = [[UIView alloc] init];
                backgroundView.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1];
                backgroundView.frame = CGRectMake(-weakSelf.view.width, 0, weakSelf.view.width * 3, 60);
                weakSelf.backgroundView = backgroundView;
                
                array = @[line,backgroundView];
            }
            array.firstObject.centerXValue((1 - progress) * fromCell.centerX + progress * toCell.centerX);
            
            return array;
        });
    };
}

- (UICollectionView *)collectionView {
    
    CGFloat itemWH = (self.view.width - 40) / 2;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 15, 15);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake(itemWH, itemWH + 85);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
    [collectionView registerClass:[CyclePageViewTaoBaoDemoCell class] forCellWithReuseIdentifier:NSStringFromClass(CyclePageViewTaoBaoDemoCell.class)];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = UIColor.clearColor;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    if (@available(iOS 10.0, *)) {
        collectionView.prefetchingEnabled = NO;
    }
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(CyclePageViewTaoBaoDemoCell.class)
                                              forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    return cell;
}

- (NSMutableArray<UILabel *> *)subTitleLabelArray {
    if (!_subTitleLabelArray){
        _subTitleLabelArray = @[].mutableCopy;;
    }
    return _subTitleLabelArray;
}

- (NSMutableArray<UIView *> *)lines {
    if (!_lines){
        _lines = @[].mutableCopy;;
    }
    return _lines;
}

@end
