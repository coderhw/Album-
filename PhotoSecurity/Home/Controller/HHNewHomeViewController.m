//
//  HHNewHomeViewController.m
//  PhotoSecurity
//
//  Created by vanke on 2019/7/29.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHNewHomeViewController.h"
#import "HHAlbumDetailViewController.h"
#import "GHPopupEditView.h"
#import "XPAlbumCell.h"
#import "HHAlbumModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <QuartzCore/CALayer.h>
//
#import "HHAlbumCollectionViewCell.h"

static NSString *cellIdentifier = @"gridcellidentifier";

@interface HHNewHomeViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,
UICollectionViewDataSource, UICollectionViewDelegate>

/// 用户的相册数据
@property (nonatomic, strong) NSMutableArray<HHAlbumModel *> *userAlbums;
/// 是否需要重新排序
@property (nonatomic, assign, getter=isReSequence)BOOL reSequence;
@property (nonatomic, strong)UICollectionView   *collectionView;
@property (nonatomic, strong)NSMutableArray *datasource;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;

@end

@implementation HHNewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    self.navigationItem.leftBarButtonItem = self.leftBarButtton;
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    self.view.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
    self.navigationItem.title = NSLocalizedString(@"Album", nil);
    self.collectionView = [[UICollectionView alloc]
                           initWithFrame:CGRectMake(16, 16, APP_WIDTH-32, APP_HEIGTH-Height_NavBar-78-Height_StatusBar)
                           collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HHAlbumCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.userAlbums = [[HHSQLiteManager sharedSQLiteManager] requestUserAlbums];
    [self.collectionView reloadData];
}

- (NSMutableArray *)datasource {
    if (_datasource == nil) {
        _datasource = [[NSMutableArray alloc] init];
    }
    return _datasource;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HHAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                  forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5.0f;
    cell.layer.masksToBounds = YES;
    
    HHAlbumModel *album = self.userAlbums[indexPath.row];
    [cell configCellWithAlbumModel:album];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HHAlbumModel *album = self.userAlbums[indexPath.row];
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HHAlbumDetailViewController *detailVC = [mainBoard instantiateViewControllerWithIdentifier:@"HHAlbumDetailViewController"];
    detailVC.album = album;
    [self.navigationController pushViewController:detailVC animated:YES];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(APP_WIDTH/4, 160);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userAlbums.count;
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = NSLocalizedString(@"No albums", nil);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"#666666"]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = NSLocalizedString(@"No albums, please create an album to facilitate the storage of photos.", nil);
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont fontWithName:kTitleName_PingFang_R size:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    NSString *text = NSLocalizedString(@"Create a new album", nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"#666666"]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"home-album"];
}

#pragma mark - <DZNEmptyDataSetDelegate>

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self showCreateAlbumAlert];
}

#pragma mark - Actions

- (IBAction)addButtonAction:(UIBarButtonItem *)sender {
    [self showCreateAlbumAlert];
}

#pragma mark - Private

/**
 显示创建相册名称的弹窗
 */
- (void)showCreateAlbumAlert {
    
    GHPopupEditView *popupView = [[GHPopupEditView alloc] init];
    [popupView setTitle:NSLocalizedString(@"Please enter the album name", nil)];
    [popupView setPlaceholderString:NSLocalizedString(@"Album name", nil)];
    [popupView setOKButtonThemeColor:[UIColor colorWithHex:@"#666666"]];
    [popupView setCancelButtonThemeColor:[UIColor colorWithHex:@"#666666"]];
    [popupView setVerifyHandler:^(NSString *text) {
        NSString *albumName = [text trim];
        if (albumName.length == 0) {
            return NSLocalizedString(@"Album name can not be empty", nil);
        }
        return @"";
    }];
    @weakify(self);
    [popupView setCompletionHandler:^(NSString *text) {
        @strongify(self);
        NSString *name = [text trim];
        HHSQLiteManager *manager = [HHSQLiteManager sharedSQLiteManager];
        HHAlbumModel *album = [manager createAlbumWithName:name];
        if (nil == album) return;
        [self.userAlbums addObject:album];
        [self.collectionView reloadData];
    }];
    [popupView show];
}

- (void)rightBarButttonPressed {
    
}

- (void)leftBarButttonPressed {
    
}

- (UIBarButtonItem *)rightBarButton {
    
    if(!_rightBarButton){
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 20)];
        [button setImage:[UIImage imageNamed:@"edit_image.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -45);
        [button addTarget:self action:@selector(rightBarButttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _rightBarButton;
}

- (UIBarButtonItem *)leftBarButtton {
    
    if(!_leftBarButtton){
        
        UIButton *letButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 32)];
        [letButton setImage:[UIImage imageNamed:@"edit_image.png"] forState:UIControlStateNormal];
        [letButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        letButton.titleLabel.font = kFONT(kTitleName_PingFang_R, 18);
        letButton.imageEdgeInsets = UIEdgeInsetsMake(0, -45, 0, 0);
        [letButton addTarget:self action:@selector(leftBarButttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _leftBarButtton = [[UIBarButtonItem alloc] initWithCustomView:letButton];
    }
    return _leftBarButtton;
}

@end

