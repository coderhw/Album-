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
#import "HHNewSettingViewController.h"
//
#import "HHAlbumCollectionViewCell.h"
#import "HHBlurAlertView.h"
#import "DragView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>



static NSString *cellIdentifier = @"gridcellidentifier";

@interface HHNewHomeViewController ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,
UICollectionViewDataSource, UICollectionViewDelegate,GADBannerViewDelegate,GADInterstitialDelegate>

/// 用户的相册数据
@property (nonatomic, strong) NSMutableArray<HHAlbumModel *> *userAlbums;
/// 是否需要重新排序
@property (nonatomic, assign, getter=isReSequence)BOOL reSequence;
@property (nonatomic, strong) UICollectionView   *collectionView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, strong) UIBarButtonItem *settingButtton;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet DragView *addButton;

@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) HHBlurAlertView *blurAlertView;
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnBottomPading;

@end

@implementation HHNewHomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Album", nil);

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.navigationItem.leftBarButtonItem = self.settingButtton;
    self.navigationItem.rightBarButtonItems = @[self.editButton];
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
    self.addBtnBottomPading.constant = 60;
    
    self.addButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.addButton.layer.shadowOpacity = 0.5;
    self.addButton.layer.shadowOffset = CGSizeMake(0.5, 0.5);
    
    [self.view addSubview:self.bannerView];
    self.bannerView.delegate = self;
    [self.bannerView loadRequest:[GADRequest request]];
    [self.view bringSubviewToFront:self.bannerView];
    
    
    self.interstitial = [self createAndLoadInterstitial];

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.userAlbums = [[HHSQLiteManager sharedSQLiteManager] requestUserAlbums];
    [self.collectionView reloadData];
    self.navigationController.toolbar.hidden = YES;
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([HHPasswordTool isSetPassword] &&
           [UIApplication sharedApplication].applicationState != UIApplicationStateActive){
            //如果设置了密码则去密码页面
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
    });
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
        [cell shakes];
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

                    [SVProgressHUD showWithStatus:NSLocalizedString(@"Delete fail.", nil)];
                });
                return;
            }
            
            [self.userAlbums removeObjectAtIndex:indexPath.row];
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

- (GADInterstitial *)createAndLoadInterstitial {
    
    NSString *uintID = kEnvironment ? @"ca-app-pub-4714556776467699/1329687562" :@"ca-app-pub-3940256099942544/4411468910";
    
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:uintID];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)showTheInterstitialAd {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.interstitial.isReady) {
            [self.interstitial presentFromRootViewController:self];
        } else {
            NSLog(@"Ad wasn't ready");
        }
    });
    
}

#pragma mark - Actions

- (IBAction)addButtonAction:(UIBarButtonItem *)sender {
    [self showCreateAlbumAlert];
}

#pragma mark - GAD Delegate
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
}


- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}


- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}


- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
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
    
    HHNewSettingViewController *settVC = [[HHNewSettingViewController alloc] init];
    [self.navigationController pushViewController:settVC animated:YES];
}

- (IBAction)addAlbumButtonPressed:(UIButton *)sender {

    __weak typeof(self) ws = self;
    [sender zoom];
    [self.blurAlertView show];
    
    self.blurAlertView.alertActionBlock = ^(NSInteger index, NSString *name) {
        
        if(index == 1){
            //创建相册
            HHSQLiteManager *manager = [HHSQLiteManager sharedSQLiteManager];
            HHAlbumModel *album = [manager createAlbumWithName:name];
            if (nil == album) return;
            [ws.userAlbums addObject:album];
            [ws.collectionView reloadData];
            
            [ws showTheInterstitialAd];
        }
    };
}

- (UIBarButtonItem *)editButton {
    
    if(!_editButton){
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 44)];
        [button setImage:[UIImage imageNamed:@"icon-edit"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
        [button addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _editButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _editButton;
}

- (UIBarButtonItem *)settingButtton {
    
    if(!_settingButtton){
        UIButton *letButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [letButton setImage:[UIImage imageNamed:@"icon-setting"] forState:UIControlStateNormal];
        letButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [letButton addTarget:self action:@selector(settingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _settingButtton = [[UIBarButtonItem alloc] initWithCustomView:letButton];
    }
    return _settingButtton;
}

- (HHBlurAlertView *)blurAlertView {
    
    if(!_blurAlertView){
        _blurAlertView = [HHBlurAlertView blurAlertView];
    }
    return _blurAlertView;
}

- (GADBannerView *)bannerView {
    
    if(!_bannerView){
        _bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(APP_WIDH, 50)) origin:CGPointMake(0, APP_HEIGTH-Height_NavBar-50)];        
        NSString *unitId = kEnvironment ? @"ca-app-pub-4714556776467699/1329687562": @"ca-app-pub-3940256099942544/2934735716";
        _bannerView.adUnitID = unitId;
        _bannerView.rootViewController = self;
    }
    return _bannerView;
}

@end

