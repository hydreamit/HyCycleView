//
//  HYImageViewCell.h
//  HYCycleViewDemo
//
//  Created by Hy on 16/5/17.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCycleView.h"

@interface HYImageViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) HYCycleViewScrollDirection scrollDirection;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end
