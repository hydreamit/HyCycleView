//
//  HYContentViewModel.h
//  HYCycleViewDemo
//
//  Created by jsb06 on 16/5/17.
//  Copyright © 2016年 jsb06. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYContentViewModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, strong) NSArray *content;
+ (instancetype)contentViewModelWithDict:(NSDictionary *)dict;
@end
