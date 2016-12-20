//
//  HYImageViewCell.m
//  HYCycleViewDemo
//
//  Created by Hy on 16/5/17.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HYImageViewCell.h"
#import "HYCycleView.h"

@interface HYImageViewCell () <HYCycleViewDelegate>
@property (nonatomic, strong) HYCycleView *cycleView;
@end

@implementation HYImageViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _cycleView = [HYCycleView CycleViewWithFrame:self.bounds NetImageUrlArray:nil placeholderImage:@"two" timerStyle:HYCycleViewTimerStart];
        _cycleView.scrollDirection = HYCycleViewScrollBottom;
        _cycleView.pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
        _cycleView.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        _cycleView.imageViewContentMode = UIViewContentModeScaleAspectFill;
        _cycleView.delegate = self;
        [self.contentView addSubview:_cycleView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _cycleView.frame = self.contentView.bounds;
}

- (void)cycleView:(HYCycleView *)cycleView didSelectAtIndex:(NSInteger)index
{
    NSLog(@"点击了第==========%zd=======页", index);
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    _cycleView.NetImageUrlArray = images;
}

- (void)setScrollDirection:(HYCycleViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    _cycleView.scrollDirection = scrollDirection;
    
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    _timeInterval = timeInterval;
    _cycleView.timeInterval = timeInterval;
}

@end
