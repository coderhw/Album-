//
//  HHSetPasswordViewController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/7/25.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHSetPasswordViewController.h"
#import "PPLockView.h"
#import "NSDate+Category.h"

@interface HHSetPasswordViewController ()<PPLockViewDelegate>

@property (nonatomic, copy) NSString *firstPsd;
@property (nonatomic, copy) NSString *secondPsd;
@property (nonatomic, copy) NSString *tempPassword;
@property (nonatomic, strong) PPLockView *lockView;
@property (nonatomic, assign) NSInteger wrongTimes;

@property (nonatomic, strong) UIBarButtonItem *passwordTipButton;

@property (weak, nonatomic) IBOutlet UIButton *delePasswordBtn;
@property (nonatomic, assign) BOOL isDeletePassword;

@end

@implementation HHSetPasswordViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGTH)];
    [bg setImage:[UIImage imageNamed:@"Img_setPassword_bg.png"]];
    [self.view addSubview:bg];

   
    [self.view addSubview:self.lockView];
    
    if([HHPasswordTool isSetPassword]){
    
        self.lockView.tipsLabel.hidden = YES;
    }else{
        
        self.lockView.tipsLabel.hidden = NO;
    }
    
    if(self.isChangePsd) {
        
        self.lockView.tipsLabel.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.passwordTipButton;
    }
    
    self.wrongTimes = 0;
    self.delePasswordBtn.hidden = !self.isChangePsd;
    [self.delePasswordBtn setTitle:NSLocalizedString(@"Delete password", nil) forState:UIControlStateNormal];
    [self.delePasswordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.delePasswordBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.view bringSubviewToFront:self.delePasswordBtn];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self showTips];
    NSLog(@"%s", __func__);
}

- (void)lockViewUnlockWithPasswd:(NSString *)passoword {

    self.tempPassword = passoword;
    NSLog(@"pass:%@", passoword);
    
    if(self.isDeletePassword){
        BOOL isCorrectPsd = [HHPasswordTool verifyPassword:passoword];
        if(isCorrectPsd){
            //删除手势密码
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:XPPasswordKey];
            //删除生物识别
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:XPTouchEnableStateKey];
            self.lockView.tipsLabel.text = NSLocalizedString(@"Password already deleted", nil);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [self.lockView shake];
            self.lockView.tipsLabel.text = NSLocalizedString(@"Please enter correct password for delete", nil);
        }
    }else{
        
        
        //已经设置过密码
        if([HHPasswordTool isSetPassword]){
            
            if(self.isChangePsd){
                [self setPasswordWithPassword:passoword];
            }else{
                
                BOOL isCorrectPsd = [HHPasswordTool verifyPassword:passoword];
                if(isCorrectPsd){
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        //处理解锁后的事情
                        [self saveCurrentLoginTime];
                    }];
                }else{
                    
                    self.lockView.tipsLabel.text = NSLocalizedString(@"Password is wrong, please try again.", nil);
                    [self.lockView shake];
                    self.wrongTimes ++;
                    if(self.wrongTimes >=3){
                        NSString *tips = [[NSUserDefaults standardUserDefaults] valueForKey:HHPasswordTipKey];
                        if(tips && tips.length){
                            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Password tips", nil), tips]];
                            self.wrongTimes = 0;
                        }
                    }
                }
            }
        }else{
            [self setPasswordWithPassword:self.tempPassword];
        }
    }

}

- (void)setPasswordWithPassword:(NSString *)password {
    
    //没设置过密码
    if(self.firstPsd.length){
        
        self.secondPsd = password;
        if([self.firstPsd isEqualToString:self.secondPsd]){
            [HHPasswordTool storagePassword:self.secondPsd];
                if(self.isChangePsd){
                    self.lockView.tipsLabel.text = NSLocalizedString(@"Password set success", nil);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:nil];
                    });
                }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.lockView shake];
                self.lockView.tipsLabel.text = NSLocalizedString(@"Not match, Please enter again", nil);
                self.firstPsd = @"";
                self.secondPsd = @"";
                self.tempPassword = @"";
            });

        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{

            self.lockView.tipsLabel.text = NSLocalizedString(@"Please set Gesture Password again", nil);
            self.firstPsd = self.tempPassword;
        });
    }
}

- (IBAction)deletePasswordPressed:(UIButton *)sender {
    
    if([HHPasswordTool isSetPassword]){
        sender.selected = !sender.selected;
        self.isDeletePassword = sender.selected;
        self.lockView.tipsLabel.text = NSLocalizedString(@"Please enter correct password for delete", nil);
    }else{
        self.lockView.tipsLabel.text = NSLocalizedString(@"Please set password first", nil);
    }
}

#pragma mark - Private
- (void)saveCurrentLoginTime {
    
    NSString *today = [NSDate getCurrentDay];
    NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:@"kUnlockTimesKey"];
    times++;
    //保存锁屏次数
    [[NSUserDefaults standardUserDefaults] setInteger:times forKey:@"kUnlockTimesKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *unlockTimesKey = [NSString stringWithFormat:@"%@_%ld", today, (long)times];
    NSString *unlockFiveTimesKey = [NSString stringWithFormat:@"%@_%d", today, 3];
    NSLog(@"unlockTimesKey:%@",unlockTimesKey);
    NSLog(@"unlockFiveTimesKey:%@",unlockFiveTimesKey);
    if([unlockTimesKey isEqualToString:unlockFiveTimesKey]){
        //解锁3次展示广告
        [[NSNotificationCenter defaultCenter] postNotificationName:HHFiveTimeLoginKey object:nil];
        //清除登录次数
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUnlockTimesKey"];
    }

}

- (void)showTips {
    self.lockView.tipsLabel.hidden = NO;
    self.lockView.tipsLabel.text = NSLocalizedString(@"Please enter password", nil);
}

- (void)passwordTipButton:(UIButton *)sender {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Password Tips", nil)
                                                                     message:NSLocalizedString(@"Remind you when forget password", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Please enter tips", nil);
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *tipTF = alertVC.textFields.firstObject;
        if(tipTF.text.length){
            [[NSUserDefaults standardUserDefaults] setValue:tipTF.text forKey:HHPasswordTipKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                       style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];

}

#pragma mark - Getter Methods

- (PPLockView *)lockView {
    
    if(!_lockView){
        _lockView = [[PPLockView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGTH)];
        _lockView.delegate = self;
        _lockView.tipBlock = ^{
            NSString *tips = [[NSUserDefaults standardUserDefaults] valueForKey:HHPasswordTipKey];
            if(tips && tips.length){
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Password tips", nil), tips]];
            }

        };
    }
    return _lockView;
}

#pragma mark - Getter
- (UIBarButtonItem *)passwordTipButton {
    
    if(!_passwordTipButton){
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 44)];
        [button setTitle:NSLocalizedString(@"Password Tips", nil) forState:UIControlStateNormal];
        [button.titleLabel setFont:kFONT(kTitleName_PingFang_R, 12)];
        [button addTarget:self action:@selector(passwordTipButton:) forControlEvents:UIControlEventTouchUpInside];
        _passwordTipButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    return _passwordTipButton;
}
@end
