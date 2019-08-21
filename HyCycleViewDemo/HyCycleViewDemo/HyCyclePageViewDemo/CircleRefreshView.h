//
//  CircleRefreshView.h
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CircleRefreshView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign, readonly) BOOL animationing;

- (void)startAnimation;
- (void)stopAnimation;

@end

