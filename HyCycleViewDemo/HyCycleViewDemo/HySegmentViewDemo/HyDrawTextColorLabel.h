//
//  HyDrawTextColorLabel.h
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/25.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HyDrawTextColorLabel : UILabel

- (void)drawTextColor:(UIColor *)color
             progress:(CGFloat)progress;

- (void)drawTextColor:(UIColor *)color
                 rect:(CGRect)rect;
@end


