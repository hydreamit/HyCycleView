//
//  HyCustomView.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 16/5/4.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HyCustomView.h"


@interface HyCustomView ()
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *subL;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *iamgeView3;
@property (nonatomic, strong) NSArray<UIImageView *> *imageViews;
@end


@implementation HyCustomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageViews = @[self.imageView1, self.imageView2, self.iamgeView3];
}

- (void)setDict:(NSDictionary *)dict {
    
    _dict = dict;

    self.titleL.text = dict[@"title"];
    self.subL.text = dict[@"subTitle"];
    NSArray *images = dict[@"content"];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        if (idx < images.count) {
            obj.image = [UIImage imageNamed:images[idx]];
            obj.hidden = NO;
        } else {
            obj.hidden = YES;
        }
    }];
}

@end
