//
//  HYContentViewModel.m
//  HYCycleViewDemo
//
//  Created by Hy on 16/5/17.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HYContentViewModel.h"

@implementation HYContentViewModel
+ (instancetype)contentViewModelWithDict:(NSDictionary *)dict
{
    HYContentViewModel *model = [[HYContentViewModel alloc] init];
    [model setValuesForKeysWithDictionary:dict];
    return model;
}
@end
