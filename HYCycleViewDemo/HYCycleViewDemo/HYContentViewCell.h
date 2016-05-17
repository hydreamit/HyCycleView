//
//  HYContentViewCell.h
//  HYCycleViewDemo
//
//  Created by jsb06 on 16/5/17.
//  Copyright © 2016年 jsb06. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCycleView.h"

@interface HYContentViewCell : UITableViewCell
@property (nonatomic, strong) NSMutableArray *contentViewModels;
@property (nonatomic, assign) HYCycleViewScrollDirection scrollDirection;
@end
