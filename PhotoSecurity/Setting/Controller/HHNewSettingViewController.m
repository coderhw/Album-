//
//  HHNewSettingViewController.m
//  PhotoSecurity
//
//  Created by huwen on 2019/8/1.
//  Copyright © 2019 huwen. All rights reserved.
//

#import "HHNewSettingViewController.h"
#import "HHSettingCell.h"
#import "XPSettingCell.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "HHSetPasswordViewController.h"
#import "XPFTPViewController.h"
#import "HHSetEmailViewContrller.h"
#import "HHChangeIconViewController.h"
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import "HHChangePressController.h"

@interface HHNewSettingViewController ()<UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) LAContext *context;


@end

@implementation HHNewSettingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    self.context = [[LAContext alloc] init];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDH,
                                                                   APP_HIGH-Height_NavBar)
                                                  style:UITableViewStylePlain];
    [self.tableView registerNib:[UINib nibWithNibName:@"HHSettingCell" bundle:nil] forCellReuseIdentifier:@"HHSettingCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    //Face ID
    HHRowsModel *row0Model = [[HHRowsModel alloc] init];
    row0Model.imageName = @"faceID.png";
    row0Model.title = @"Touch IDs/Face IDs";
    row0Model.footerTips = NSLocalizedString(@"Quick unlock by this way", nil);
    [self.dataSource addObject:row0Model];
   
    //修改密码
    HHRowsModel *row1Model = [[HHRowsModel alloc] init];
    row1Model.imageName = @"change_psd.png";
    row1Model.title = NSLocalizedString(@"Password", nil);
    row1Model.footerTips = NSLocalizedString(@"Setting or modify or delete password", nil);
    [self.dataSource addObject:row1Model];
    
    //ftp
    HHRowsModel *row2Model = [[HHRowsModel alloc] init];
    row2Model.imageName = @"ftp.png";
    row2Model.title = NSLocalizedString(@"FTP transfer service", nil);
    row2Model.footerTips = NSLocalizedString(@"Quick transfer Date by this way", nil);
    [self.dataSource addObject:row2Model];
    
    //找回密码icon
    HHRowsModel *row3Model = [[HHRowsModel alloc] init];
    row3Model.imageName = @"fine_psd.png";
    row3Model.title = NSLocalizedString(@"Find your password", nil);
    row3Model.footerTips = NSLocalizedString(@"Email need Before this service", nil);
    [self.dataSource addObject:row3Model];
    
    //切换icon
    HHRowsModel *row4Model = [[HHRowsModel alloc] init];
    row4Model.imageName = @"changeicon.png";
    row4Model.title = NSLocalizedString(@"Change App icon", nil);
    row4Model.footerTips = NSLocalizedString(@"Change Your App icon whenever", nil);
    [self.dataSource addObject:row4Model];
    
    //切换icon
    HHRowsModel *row8Model = [[HHRowsModel alloc] init];
    row8Model.imageName = @"icon_press.png";
    row8Model.title = NSLocalizedString(@"Compression ratio", nil);
    row8Model.footerTips = NSLocalizedString(@"determine your Image should be compression, Default no", nil);
    [self.dataSource addObject:row8Model];


    //评分icon
    HHRowsModel *row6Model = [[HHRowsModel alloc] init];
    row6Model.imageName = @"score.png";
    row6Model.title = NSLocalizedString(@"AppStore grade", nil);
    row6Model.footerTips = NSLocalizedString(@"Give me five star, thanks", nil);
    [self.dataSource addObject:row6Model];
    
    //版本icon
    HHRowsModel *row7Model = [[HHRowsModel alloc] init];
    row7Model.imageName = @"icon_version.png";
    row7Model.title = NSLocalizedString(@"Upgrade", nil);
    [self.dataSource addObject:row7Model];
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    HHSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HHSettingCell"];
    HHRowsModel *rowModel = [self.dataSource objectAtIndex:indexPath.row];
    [cell configCellWith:rowModel withRow:indexPath.row];
    cell.passwordSwitchBlock = ^(UISwitch * _Nonnull sender) {
        [weakSelf handlePasswordSetting:sender];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 1:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NSString *identifier =  @"HHSetPasswordViewController";
            HHSetPasswordViewController *vc = (HHSetPasswordViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:identifier];
            vc.isChangePsd = YES;
            vc.navigationItem.title = NSLocalizedString(@"Change Password", nil);
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NSString *identifier =  @"XPFTPViewController";
            XPFTPViewController *vc = (XPFTPViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:identifier];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 3:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NSString *identifier =  @"HHSetEmailViewContrller";
            HHSetEmailViewContrller *vc = (HHSetEmailViewContrller *)[mainStoryboard instantiateViewControllerWithIdentifier:identifier];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NSString *identifier =  @"HHChangeIconViewController";
            HHChangeIconViewController *vc = (HHChangeIconViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:identifier];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 5:
        {
            //压缩比设置
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NSString *identifier =  @"HHChangePressController";
            HHChangePressController *vc = (HHChangePressController *)[mainStoryboard instantiateViewControllerWithIdentifier:identifier];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:
        {
            if (@available(iOS 10.3, *)) {
                [SKStoreReviewController requestReview];
            }
        }
            break;
        case 7:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - MFMailDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Thanks for your feedback", nil)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private
- (void)handlePasswordSetting:(UISwitch *)sender {
    if([HHPasswordTool isSetPassword]){
        //必须要先设置密码
        if (touchIDTypeEnabled() == 1) {
            // 已开启,则关闭指纹解锁
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLocalizedString(@"Make sure you want to turn off Touch ID?", nil) message:NSLocalizedString(@"", nil)
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [sender setOn:YES];
                                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                          [userDefaults setValue:@"1" forKey:XPTouchEnableStateKey];
                                                          [userDefaults synchronize];
                                                          
                                                      }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        [sender setOn:NO];
                                                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                        [userDefaults removeObjectForKey:XPTouchEnableStateKey];        }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if (touchIDTypeEnabled() == 2) {
            
            // 已开启,则关毕面容解锁
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLocalizedString(@"Make sure you want to turn off Face ID?", nil) message:NSLocalizedString(@"", nil)
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                          [sender setOn:YES];
                                                          [userDefaults setValue:@"2" forKey:XPTouchEnableStateKey];
                                                          [userDefaults synchronize];
                                                          
                                                      }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [sender setOn:NO];
                                                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                        [userDefaults removeObjectForKey:XPTouchEnableStateKey];
                                                    }]];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            
            NSError *error = nil;
            BOOL isAvailable = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            if (!isAvailable) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender setOn:NO];
                });

                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }
            
            __weak typeof(self) weakSelf = self;
            [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                     localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil) reply:^(BOOL success, NSError * _Nullable error) {
                         
                         if (!success) {
                             
                             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                             return;
                         }else{
                             
                             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                             NSString *type = [NSString stringWithFormat:@"%ld", (long)touchIDTypeAccessed()];
                             [userDefaults setValue:type forKey:XPTouchEnableStateKey];
                             [userDefaults synchronize];
                             //Face ID
                             if(@available(iOS 11.0, *)) {
                                 if (weakSelf.context.biometryType == LABiometryTypeFaceID){
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [sender setOn:YES];

                                         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Face ID successed set", nil)];
                                     });
                                 }
                                 
                             }
                             //指纹
                             if (@available(iOS 11.0, *)) {
                                 if(weakSelf.context.biometryType == LABiometryTypeTouchID){
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [sender setOn:YES];
                                         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Touch ID successed set", nil)];
                                     });
                                 }
                             } else {
                                 // Fallback on earlier versions
                             }
                             
                             
                         }
                     }];
        }
    }else{

        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Please set Password before use Touch ID/Face ID", nil)];
    }
    
}

- (NSMutableArray *)dataSource {
    if(!_dataSource){
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end

@implementation HHRowsModel
@end
