//
//  HHSettingViewController.m
//  PhotoSecurity
//
//  Created by nhope on 2017/3/20.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "HHSettingViewController.h"
#import "XPSettingCell.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "HHSetPasswordViewController.h"

@interface HHSettingViewController ()

@property (nonatomic, strong) LAContext *context;
@end

@implementation HHSettingViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    self.context = [[LAContext alloc] init];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.tableView.tableFooterView sizeToFit];
}

- (void)dealloc {
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    XPSettingCell *settingCell = (XPSettingCell *)cell;
    if (0 == indexPath.section) {
        [settingCell.stateSwitch setHidden:NO];
        NSInteger isOn = touchIDTypeEnabled() == 0 ? 0 : 1;
        [settingCell.stateSwitch setOn:isOn];
        [settingCell.stateSwitch addTarget:self
                                    action:@selector(stateSwitchAction:)
                          forControlEvents:UIControlEventValueChanged];
        
        if(touchIDTypeAccessed() == 1){
            [settingCell.titleLabel setText:NSLocalizedString(@"Fingerprints are unlocked", nil)];
        }else if(touchIDTypeAccessed() == 2){
            [settingCell.titleLabel setText:NSLocalizedString(@"FaceID are unlocked", nil)];
        }
        
    } else if (1 == indexPath.section) {
        
        [settingCell.titleLabel setText:NSLocalizedString(@"Change Password", nil)];
        [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    } else if (2 == indexPath.section) {
        
        [settingCell.titleLabel setText:NSLocalizedString(@"FTP Service", nil)];
        [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (1 == indexPath.section) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSString *identifier =  @"HHSetPasswordViewController";
        HHSetPasswordViewController *vc = (HHSetPasswordViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:identifier];
        vc.isChangePsd = YES;
        vc.navigationItem.title = @"修改密码";
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (2 == indexPath.section) {
        
        [self performSegueWithIdentifier:@"FTPSegue" sender:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (0 == section) {
        return NSLocalizedString(@"After opening, you can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil);
    }
    if (2 == section) {
        return NSLocalizedString(@"After opening, you can quickly copy the photos through the FTP server", nil);
    }
    return nil;
}

#pragma mark - Actions

- (void)stateSwitchAction:(UISwitch *)sender {
    
    XPSettingCell *cell = (XPSettingCell *)sender.superview.superview;
    if (touchIDTypeEnabled() == 1) {
        // 已开启,则关闭指纹解锁
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Make sure you want to turn off Touch ID?", nil) message:NSLocalizedString(@"", nil)
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                  style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                      
                                                      [cell.stateSwitch setOn:YES];
                                                      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                      [userDefaults setValue:@"1" forKey:XPTouchEnableStateKey];
                                                      [userDefaults synchronize];

        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                    [cell.stateSwitch setOn:NO];
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
                                                      [cell.stateSwitch setOn:YES];
                                                      [userDefaults setValue:@"2" forKey:XPTouchEnableStateKey];
                                                      [userDefaults synchronize];

                                                  }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil)
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [cell.stateSwitch setOn:NO];
                                                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                                    [userDefaults removeObjectForKey:XPTouchEnableStateKey];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        NSError *error = nil;
        BOOL isAvailable = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        if (!isAvailable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.stateSwitch setOn:NO];
            });
            [HHProgressHUD showFailureHUD:error.localizedDescription toView:self.view];
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil) reply:^(BOOL success, NSError * _Nullable error) {

            if (!success) {
                [HHProgressHUD showFailureHUD:error.localizedDescription toView:weakSelf.view];
                return;
            }else{
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *type = [NSString stringWithFormat:@"%ld", (long)touchIDTypeAccessed()];
                [userDefaults setValue:type forKey:XPTouchEnableStateKey];
                [userDefaults synchronize];
                [cell.stateSwitch setOn:YES];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [HHProgressHUD showSuccessHUD:NSLocalizedString(@"Face ID successed set", nil) toView:weakSelf.view];
                });
            }
        }];
    }
}


@end
