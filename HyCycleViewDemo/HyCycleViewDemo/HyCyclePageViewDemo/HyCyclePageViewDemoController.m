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


@implementation HyCyclePageViewDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"GestureStyleOnly(一个手势,不需解决手势冲突)",
//                    @"GestureStyleMultiple(多个手势,需解决手势冲突)",
                    @"TaoBaoDemo(淘宝首页)"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == self.titles.count - 1) {
        CyclePageViewTaoBaoDemoController *viewController = [[CyclePageViewTaoBaoDemoController alloc] init];
        viewController.navigationItem.title = self.titles[indexPath.row];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    } else {
        CyclePageViewStyleDemoController *viewController = [[CyclePageViewStyleDemoController alloc] init];
        viewController.navigationItem.title = self.titles[indexPath.row];
        viewController.gestureStyle = indexPath.row == 0 ? HyCyclePageViewGestureStyleOnly : HyCyclePageViewGestureStyleMultiple;
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }
}

@end
