//
//  HYContentView.m
//  ScrollView
//
//  Created by Hy on 16/5/4.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HYContentView.h"
#import "HYContentViewModel.h"

@interface HYContentView ()
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *subL;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *iamgeView3;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) HYContentViewModel *model; // 默认名字
@property (nonatomic, strong) HYContentViewModel *HYModel;
@end

@implementation HYContentView
- (void)awakeFromNib
{
    self.images = @[self.imageView1, self.imageView2, self.iamgeView3];
}

/**
 *  方式一
 *
 */
- (void)setModel:(HYContentViewModel *)model
{
    _model = model;
    
    self.titleL.text = model.title;
    self.subL.text = model.subTitle;
    NSArray *images = model.content;
    for (int i = 0; i<self.images.count; i++) {
        UIImageView *PictureView = self.images[i];
        if (i < images.count) {
            PictureView.image = [UIImage imageNamed:images[i]];
            PictureView.hidden = NO;
        } else {
            PictureView.hidden = YES;
        }
    }
}




/**
 *  方式二
 *
 */
//- (void)setHYModel:(HYContentViewModel *)HYModel
//{
//    _HYModel = HYModel;
//    
//    self.titleL.text = HYModel.title;
//    self.subL.text = HYModel.subTitle;
//    NSArray *images = HYModel.content;
//    for (int i = 0; i<self.images.count; i++) {
//        UIImageView *PictureView = self.images[i];
//        if (i < images.count) {
//            PictureView.image = [UIImage imageNamed:images[i]];
//            PictureView.hidden = NO;
//        } else {
//            PictureView.hidden = YES;
//        }
//    }
//}
//
//- (NSString *)SetupContentModelName //告诉传入的模型名字， 默认是model时, 当是model时不用实现这个方法
//{
//    return @"HYModel";
//}



@end
