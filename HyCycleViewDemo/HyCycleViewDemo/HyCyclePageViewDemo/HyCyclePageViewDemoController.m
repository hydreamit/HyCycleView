//
//  HyCyclePageViewDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "HyCyclePageViewDemoController.h"
#import "CyclePageViewStyleDemoController.h"
#import "CyclePageViewTaoBaoDemoController.h"
#import "CyclePageViewTikTokDemoController.h"


@implementation HyCyclePageViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"基本使用",
                    @"淘宝->首页",
                    @"抖音->我"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *viewController = nil;
    if (indexPath.row == 0) {
        viewController = [[CyclePageViewStyleDemoController alloc] init];
    } else if (indexPath.row == 1) {
        viewController = [[CyclePageViewTaoBaoDemoController alloc] init];
    } else {
        viewController = [[CyclePageViewTikTokDemoController alloc] init];
    }
    viewController.navigationItem.title = self.titles[indexPath.row];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

@end
