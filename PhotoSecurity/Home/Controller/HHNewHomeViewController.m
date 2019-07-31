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
#import "HHSettingViewController.h"
#import "HHBlurAlertView.h"

static NSString *cellIdentifier = @"gridcellidentifier";

@interface HHNewHomeViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,
UICollectionViewDataSource, UICollectionViewDelegate>

/// 用户的相册数据
@property (nonatomic, strong) NSMutableArray<HHAlbumModel *> *userAlbums;
/// 是否需要重新排序
@property (nonatomic, assign, getter=isReSequence)BOOL reSequence;
@property (nonatomic, strong) UICollectionView   *collectionView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) HHBlurAlertView *blurAlertView;
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
                           initWithFrame:CGRectMake(16, 16, APP_WIDTH-32,
                                                    APP_HEIGTH-Height_NavBar-16)
                           collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HHAlbumCollectionViewCell" bundle:nil]
          forCellWithReuseIdentifier:cellIdentifier];
    self.collectionView.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view bringSubviewToFront:self.addButton];
    
    self.titleStr = NSLocalizedString(@"Album", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.userAlbums = [[HHSQLiteManager sharedSQLiteManager] requestUserAlbums];
    [self.collectionView reloadData];
    self.navigationController.toolbar.hidden = YES;
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    // 打开应用必须先解锁才能使用
    static dispatch_once_t onceToken;
    @weakify(self);
    dispatch_once(&onceToken, ^{
        @strongify(self);
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSString *identifier = @"HHSetPasswordViewController";
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        [self presentViewController:vc animated:NO completion:nil];

    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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

    if(self.isEditing){
        [cell configCellWithAlbumModel:album isEdit:YES];
    }else{
        [cell configCellWithAlbumModel:album isEdit:NO];
    }
    
    cell.deleblock = ^{
        //删除相册
        HHAlbumModel *album = self.userAlbums[indexPath.row];
        NSString *title = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Delete", nil),album.name];
        NSString *message = NSLocalizedString(@"Are you sure you want to delete the album? All the pictures under the album will be deleted.", nil);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        @weakify(self);
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Album", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            HHAlbumModel *album = self.userAlbums[indexPath.row];
            BOOL success = [[HHSQLiteManager sharedSQLiteManager] deleteAlbumWithAlbum:album];
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HHProgressHUD showFailureHUD:NSLocalizedString(@"Delete fail.", nil) toView:self.view];
                });
                return;
            }
            [self.userAlbums removeObjectAtIndex:indexPath.row];
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];

            if (0 == self.userAlbums.count) {
                [self.collectionView reloadEmptyDataSet];
            }
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        if (iPad()) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            alert.popoverPresentationController.sourceView = cell;
            // 直接cell.bounds会导致弹出框往左偏移不居中
            alert.popoverPresentationController.sourceRect = CGRectMake(cell.contentView.frame.origin.x, 0.0, cell.bounds.size.width+ABS(cell.contentView.frame.origin.x)*2, cell.bounds.size.height);
            alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self presentViewController:alert animated:YES completion:nil];
    };
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
    
    return CGSizeMake(APP_WIDTH/2-24, 190);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userAlbums.count;
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = NSLocalizedString(@"No albums", nil);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"#333333"]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = NSLocalizedString(@"No albums, please create an album to facilitate the storage of photos.", nil);
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:kTitleName_PingFang_R size:14.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"#999999"],
                                 NSParagraphStyleAttributeName: paragraph};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    NSString *text = NSLocalizedString(@"Create a new album", nil);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithHex:@"#333333"]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -100;
}
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"empty_image"];
}

#pragma mark - <DZNEmptyDataSetDelegate>

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self addAlbumButtonPressed:nil];
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

- (void)editButtonPressed:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    self.isEditing = sender.selected;
    [self.collectionView reloadData];
}

- (void)settingButtonPressed {
    
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HHSettingViewController *settingVC = [mainBoard instantiateViewControllerWithIdentifier:@"HHSettingViewController"];
    [self.navigationController pushViewController:settingVC animated:YES];    
}

- (IBAction)addAlbumButtonPressed:(id)sender {

    __weak typeof(self) ws = self;
    [self.blurAlertView show];
    self.blurAlertView.alertActionBlock = ^(NSInteger index, NSString *name) {
        
        if(index == 1){
            //创建相册
            HHSQLiteManager *manager = [HHSQLiteManager sharedSQLiteManager];
            HHAlbumModel *album = [manager createAlbumWithName:name];
            if (nil == album) return;
            [ws.userAlbums addObject:album];
            [ws.collectionView reloadData];
        }
    };
}

- (UIBarButtonItem *)rightBarButton {
    
    if(!_rightBarButton){
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 44)];
        [button setImage:[UIImage imageNamed:@"icon-edit"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -40);
        [button addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _rightBarButton;
}

- (UIBarButtonItem *)leftBarButtton {
    
    if(!_leftBarButtton){
        UIButton *letButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 32)];
        [letButton setImage:[UIImage imageNamed:@"icon-setting"] forState:UIControlStateNormal];
        [letButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        letButton.titleLabel.font = kFONT(kTitleName_PingFang_R, 18);
        letButton.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
        [letButton addTarget:self action:@selector(settingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _leftBarButtton = [[UIBarButtonItem alloc] initWithCustomView:letButton];
    }
    return _leftBarButtton;
}

- (HHBlurAlertView *)blurAlertView {
    
    if(!_blurAlertView){
        _blurAlertView = [HHBlurAlertView blurAlertView];
    }
    return _blurAlertView;
}

@end

