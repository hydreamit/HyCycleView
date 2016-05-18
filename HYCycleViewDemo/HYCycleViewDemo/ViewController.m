//
//  ViewController.m
//  HYCycleViewDemo
//
//  Created by jsb06 on 16/5/17.
//  Copyright © 2016年 jsb06. All rights reserved.
//

#import "ViewController.h"
#import "HYContentViewCell.h"
#import "HYImageViewCell.h"
#import "HYContentViewModel.h"
#import "HYCycleView.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *HYTableView;
@property (nonatomic, strong) NSArray *netImages;
@property (nonatomic, strong) NSArray *dictArray;
@property (nonatomic, strong) NSMutableArray *contentViewModels;
@property (nonatomic, assign) NSInteger startDirection;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end

static NSString *const HYContentViewCellID = @"contentView";
static NSString *const HYImageViewCellID = @"ImageView";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.timeInterval = 1.5;
    
    _HYTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _HYTableView.delegate = self;
    _HYTableView.dataSource = self;
    _HYTableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    _HYTableView.scrollIndicatorInsets = _HYTableView.contentInset;
    _HYTableView.backgroundColor = [UIColor clearColor];
    _HYTableView.backgroundView.backgroundColor = [UIColor clearColor];
    if ([_HYTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_HYTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_HYTableView respondsToSelector:@selector(setSeparatorColor:)]) {
        [_HYTableView setSeparatorColor:[UIColor orangeColor]];
    }
    if ([_HYTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_HYTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:_HYTableView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_HYTableView registerClass:[HYImageViewCell class] forCellReuseIdentifier:HYImageViewCellID];
    [_HYTableView registerClass:[HYContentViewCell class] forCellReuseIdentifier:HYContentViewCellID];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 80) / 2, 20, 80, 35);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"刷新" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)click
{
    self.startDirection += 2;
    
    if (self.timeInterval <= 1.5) {
        self.timeInterval -= 0.5;
        if (self.timeInterval == 0) {
            self.timeInterval = 1.5;
        }
    }
    
    [_HYTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        HYImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HYImageViewCellID];
        cell.images = self.netImages;
        cell.scrollDirection = (HYCycleViewScrollDirection)((indexPath.row + 2 + self.startDirection) % 4);
        cell.timeInterval = self.timeInterval;
        return cell;
    } else {
        HYContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HYContentViewCellID];
        cell.contentViewModels = self.contentViewModels;
        cell.scrollDirection = (HYCycleViewScrollDirection)((indexPath.row + self.startDirection) % 4);
        cell.timeInterval = self.timeInterval;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 110;
    } else {
        return 180;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSArray *)netImages
{
    if (!_netImages) {
        _netImages = @[@"https://img.hdvg.tv//images/b4/49/d5/ed26f99e6e4b8c6f53a0deecde669f45c0e2c1e5.jpg",@"https://img.hdvg.tv//images/e9/ff/d4/622fb30763a708da1993f0e8b5fd2656f6c70de7.jpg", @"https://img.hdvg.tv//images/b9/58/01/1de7e2dda528b6d307bcb095a39ada6d118e0f88.jpg",@"https://img.hdvg.tv//images/b4/49/d5/ed26f99e6e4b8c6f53a0deecde669f45c0e2c1e5.jpg",@"https://img.hdvg.tv//images/e9/ff/d4/622fb30763a708da1993f0e8b5fd2656f6c70de7.jpg", @"https://img.hdvg.tv//images/b9/58/01/1de7e2dda528b6d307bcb095a39ada6d118e0f88.jpg"];
    }
    return _netImages;
}

- (NSArray *)dictArray
{
    if (!_dictArray) {
        _dictArray = @[
                       @{ @"title" : @"春晓",
                           @"subTitle" : @"春眠不觉晓",
                           @"content" : @[@"one", @"two", @"three"]
                        },
                       @{ @"title" : @"春晓",
                          @"subTitle" : @"处处蚊子咬",
                          @"content" : @[@"four", @"five", @"six"]
                          },
                       @{ @"title" : @"春晓",
                          @"subTitle" : @"夜来风雨声",
                          @"content" : @[@"three", @"two"]
                          },
                       @{ @"title" : @"春晓",
                          @"subTitle" : @"花落知多少",
                          @"content" : @[@"six"]
                          },
                        ];
    }
    return _dictArray;
}

- (NSMutableArray *)contentViewModels
{
    if (!_contentViewModels) {
        _contentViewModels = [NSMutableArray array];
        for (NSDictionary *dict in self.dictArray) {
            HYContentViewModel *model = [HYContentViewModel contentViewModelWithDict:dict];
            [_contentViewModels addObject:model];
        }
    }
    return _contentViewModels;
}


@end
