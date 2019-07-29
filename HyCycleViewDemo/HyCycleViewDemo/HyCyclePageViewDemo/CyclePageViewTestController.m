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

@interface CyclePageViewTestController ()

@end

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

@end
