//
//  CyclePageViewDemoTestController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/20.
//  Copyright © 2016年 Hy. All rights reserved.
//

#import "CyclePageViewDemoTestController.h"

@interface CyclePageViewDemoTestController ()
@property (nonatomic, assign) NSInteger index;
@end

@implementation CyclePageViewDemoTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 0.01;
    self.tableView.sectionFooterHeight = 0.01;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
}

- (void)configCyclePageView:(HyCycleViewProvider<HyCyclePageView *> *)provider index:(NSInteger)index {
   self.index = index;
    // 主动设置引用
    // provider.retainProvider = YES;
    // __weak typeof(self) weakSelf = self;
    // block 自动引用
    [provider view:^UIView * _Nonnull(HyCyclePageView * _Nonnull cycleView) {
        return self.view;
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    cell.textLabel.text = [NSString stringWithFormat:@"第%@页_%tu", @(self.index), indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    !self.scrollViewDidEndDragging ?:
    self.scrollViewDidEndDragging(scrollView);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
