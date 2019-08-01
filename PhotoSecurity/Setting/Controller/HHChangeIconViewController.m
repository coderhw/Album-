//
//  HHChangeIconViewController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHChangeIconViewController.h"
#import "HHChangeIconCell.h"

@interface HHChangeIconViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectRow;
@end

@implementation HHChangeIconViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"换图标";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDH,
                                                                   APP_HIGH-Height_NavBar)
                                                  style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"HHChangeIconCell" bundle:nil] forCellReuseIdentifier:@"HHChangeIconCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
}


#pragma mark - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HHChangeIconCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HHChangeIconCell"];
    [cell configCellWithRow:indexPath.row selectRow:self.selectRow];
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 46, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Private
- (void)handlePasswordSetting:(UISwitch *)sender {
    
}


@end
