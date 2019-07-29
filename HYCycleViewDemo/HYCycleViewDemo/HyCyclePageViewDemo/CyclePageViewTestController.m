//
//  CyclePageViewTestController.m
//  HyCycleViewDemo
//
//  Created by huangyi on 2019/7/28.
//  Copyright © 2019 huangyi. All rights reserved.
//

#import "CyclePageViewTestController.h"
#import "UIView+HyFrame.h"

@interface CyclePageViewTestController ()

@end

@implementation CyclePageViewTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    self.view.height -= [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top + 44 + 100;
    
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.text = @"testLabel";
    [testLabel sizeToFit];
    testLabel.centerXValue(self.view.width / 2).centerYValue(self.view.height / 2);
    [self.view addSubview:testLabel];
}

@end
