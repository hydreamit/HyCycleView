//
//  CyclePageViewTaoBaoDemoCell.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewTaoBaoDemoCell.h"
#import "UIView+HyFrame.h"


@interface CyclePageViewTaoBaoDemoCell ()
@property (nonatomic,strong) UIImageView *goodsImageView;
@property (nonatomic,strong) UILabel *goodsTitleLabel;
@property (nonatomic,strong) UILabel *goodsPriceLabel;
@end


@implementation CyclePageViewTaoBaoDemoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initConfigure];
    }
    return  self;
}

- (void)initConfigure {
    
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.goodsTitleLabel];
    [self.contentView addSubview:self.goodsPriceLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.layer.cornerRadius = 5.0;
    self.contentView.layer.masksToBounds = YES;
    
    self.goodsImageView.sizeValue(self.width, self.width);
    self.goodsTitleLabel
    .topValue(self.goodsImageView.bottom + 5)
    .leftValue(5)
    .widthValue(self.width - 10)
    .heightValue(50);
    
    self.goodsPriceLabel
     .leftIsEqualTo(self.goodsTitleLabel)
     .widthIsEqualTo(self.goodsTitleLabel)
     .heightValue(30)
     .bottomValue(self.contentView.height);
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView){
        _goodsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taobao_goods"]];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _goodsImageView;
}

- (UILabel *)goodsTitleLabel {
    if (!_goodsTitleLabel){
        _goodsTitleLabel = [[UILabel alloc] init];
        _goodsTitleLabel.font = [UIFont systemFontOfSize:15];
        _goodsTitleLabel.textColor = UIColor.darkTextColor;
        _goodsTitleLabel.numberOfLines = 2;
        _goodsTitleLabel.text = @"NBA篮球服 公牛队23号JORDAN 乔丹球衣 男女球迷版黑色城市版复";
    }
    return _goodsTitleLabel;
}

- (UILabel *)goodsPriceLabel {
    if (!_goodsPriceLabel){
        _goodsPriceLabel = [[UILabel alloc] init];
        _goodsPriceLabel.font = [UIFont systemFontOfSize:15];
        _goodsPriceLabel.textColor = [UIColor colorWithRed:255 / 255.0 green:48 / 255.0 blue:0 / 255.0 alpha:1];;
        _goodsPriceLabel.numberOfLines = 2;
        _goodsPriceLabel.text = @"¥ 1668.00";
    }
    return _goodsPriceLabel;
}

@end
