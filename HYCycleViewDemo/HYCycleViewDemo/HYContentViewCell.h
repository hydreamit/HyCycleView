//
//  HYContentViewCell.h
//  HYCycleViewDemo
//
//  Created by Hy on 16/5/17.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCycleView.h"

@interface HYContentViewCell : UITableViewCell
@property (nonatomic, strong) NSMutableArray *contentViewModels;
@property (nonatomic, assign) HYCycleViewScrollDirection scrollDirection;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end
