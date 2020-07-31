//
//  CyclePageViewTestController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/21.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewTestController.h"
#import "UIView+HyFrame.h"


@implementation CyclePageViewTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    self.view.height -= [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44 + 100;
    
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.text = @"testController";
    [testLabel sizeToFit];
    testLabel.centerXValue(self.view.width / 2).centerYValue(self.view.height / 2);
    [self.view addSubview:testLabel];
    
}

- (void)configCyclePageView:(HyCycleViewProvider<HyCyclePageView *> *)provider index:(NSInteger)index {
//    provider.retainProvider = YES;
    [provider view:^UIView * _Nonnull(HyCyclePageView * _Nonnull cycleView) {
        return self.view;
    }];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
