//
//  ViewController.m
//  HyCycleView
//  https://github.com/hydreamit/HyCycleView
//
//  Created by Hy on 2016/5/9.
//  Copyright © 2016年 Hy. All rights reserved.
//


#import "ViewController.h"
#import "UIView+HyFrame.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) UITableView *tableView;
@end


@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
       
    self.titles = @[@"HyCycleViewDemo", @"HyCyclePageViewDemo", @"HySegmentViewDemo"];
    [self.view addSubview:self.tableView];
}

#pragma mark — UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)
                                    forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *classString = [self.titles[indexPath.row] stringByAppendingString:@"Controller"];
    UIViewController *viewController = [[NSClassFromString(classString) alloc] init];
    viewController.navigationItem.title = self.titles[indexPath.row];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

#pragma mark — getters and setters
- (UITableView *)tableView {
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
