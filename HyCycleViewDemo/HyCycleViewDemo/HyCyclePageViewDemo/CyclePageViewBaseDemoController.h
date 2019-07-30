//
//  CyclePageViewBaseDemoController.h
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HyCyclePageView.h"

@interface CyclePageViewBaseDemoController : UIViewController

@property (nonatomic,assign) HyCyclePageViewGestureStyle gestureStyle;

- (UIView *)hoverView;

- (UIView *)headerView;

- (NSArray *)pageInstance;

- (void(^)(HyCyclePageViewConfigure *configure))configPageView;

@end


