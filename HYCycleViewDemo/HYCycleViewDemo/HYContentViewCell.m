//
//  HYContentViewCell.m
//  HYCycleViewDemo
//
//  Created by Hy on 16/5/17.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HYContentViewCell.h"
#import "HYCycleView.h"
#import "HYContentView.h"

@interface HYContentViewCell () <HYCycleViewDelegate>
@property (nonatomic, strong) HYCycleView *cycleView;
@end

@implementation HYContentViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _cycleView = [HYCycleView CycleViewWithFrame:self.bounds contentViewNibName:NSStringFromClass([HYContentView class]) models:nil timerStyle:HYCycleViewTimerStart];
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

- (void)setContentViewModels:(NSMutableArray *)contentViewModels
{
    _contentViewModels = contentViewModels;
    _cycleView.models = contentViewModels;
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
