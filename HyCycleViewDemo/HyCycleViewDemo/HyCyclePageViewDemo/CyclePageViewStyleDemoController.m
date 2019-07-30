//
//  CyclePageViewStyleDemoController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewStyleDemoController.h"
#import "CyclePageViewBaseDemoController.h"


@implementation CyclePageViewStyleDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"CyclePageViewBaseDemo",
                    @"CyclePageViewAnimationDemo",
                    @"CyclePageViewLoadStyleDemo",
                    @"CyclePageViewNotCycleLoopDemo",
                    @"CyclePageViewHoverOffsetDemo",
                    @"CyclePageViewNoHeaderViewDemo",
                    @"CyclePageViewCustomViewDemo",
                    @"CyclePageViewTopRefreshDemo",
                    @"CyclePageViewCenterRefreshDemo",];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *classString = [self.titles[indexPath.row] stringByAppendingString:@"Controller"];
    CyclePageViewBaseDemoController *viewController = [[NSClassFromString(classString) alloc] init];
    viewController.navigationItem.title = self.titles[indexPath.row];
    viewController.gestureStyle = self.gestureStyle;
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

@end
