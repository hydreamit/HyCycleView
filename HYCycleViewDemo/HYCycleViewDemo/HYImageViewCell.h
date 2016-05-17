//
//  HYImageViewCell.h
//  HYCycleViewDemo
//
//  Created by jsb06 on 16/5/17.
//  Copyright © 2016年 jsb06. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCycleView.h"

@interface HYImageViewCell : UITableViewCell
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) HYCycleViewScrollDirection scrollDirection;
@end
