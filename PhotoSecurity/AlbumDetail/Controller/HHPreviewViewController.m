//
//  HHPreviewViewController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/11.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHPreviewViewController.h"

@interface HHPreviewViewController ()

@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@end

@implementation HHPreviewViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.deleteButton;
    self.view.backgroundColor = [UIColor blackColor];
}

- (UIBarButtonItem *)deleteButton {
    
    if(!_deleteButton){
        
        UIButton *letButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [letButton setImage:[UIImage imageNamed:@"icon_ trash.png"] forState:UIControlStateNormal];
        [letButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -16)];
        [letButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton = [[UIBarButtonItem alloc] initWithCustomView:letButton];
    }
    return _deleteButton;
}

- (void)deleteButtonPressed {
    
    UIAlertController *sheetVC = [UIAlertController alertControllerWithTitle:@"确定要删除吗"
                                                                     message:@"数据一旦被删除后将不可恢复" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
        if(self.deleteImageBlock){
            self.deleteImageBlock(self);
        }
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [sheetVC addAction:okAction];
    [sheetVC addAction:cancleAction];
    [self presentViewController:sheetVC animated:YES completion:nil];
}

@end
