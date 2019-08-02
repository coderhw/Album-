//
//  HHSetPasswordViewController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/7/25.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHSetPasswordViewController.h"
#import "PPLockView.h"


@interface HHSetPasswordViewController ()<PPLockViewDelegate>

@property (nonatomic, copy) NSString *firstPsd;
@property (nonatomic, copy) NSString *secondPsd;
@property (nonatomic, copy) NSString *tempPassword;
@property (nonatomic, strong) PPLockView *lockView;
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
    
    if(self.isChangePsd){
        self.lockView.tipsLabel.hidden = NO;
    }
    
    self.delePasswordBtn.hidden = !self.isChangePsd;
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
            [HHProgressHUD showSuccessHUD:@"密码已清除，请注意数据安全" toView:self.view];
        }else{
            [self.lockView shake];
            self.lockView.tipsLabel.text = @"请输入历史密码";
        }
    }else{
        
        
        //已经设置过密码
        if([HHPasswordTool isSetPassword]){
            
            if(self.isChangePsd){
                [self setPasswordWithPassword:passoword];
            }else{
                
                BOOL isCorrectPsd = [HHPasswordTool verifyPassword:passoword];
                if(isCorrectPsd){
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    self.lockView.tipsLabel.text = NSLocalizedString(@"Password is wrong, please try again.", nil);
                    [self.lockView shake];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
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
                self.lockView.tipsLabel.text = @"不匹配，请重新设置";
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
    
    sender.selected = !sender.selected;
    self.isDeletePassword = sender.selected;

}


- (void)showTips {
    self.lockView.tipsLabel.hidden = NO;
    self.lockView.tipsLabel.text = @"请输入密码";
}

#pragma mark - Getter Methods

- (PPLockView *)lockView {
    
    if(!_lockView){
        _lockView = [[PPLockView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGTH)];
        _lockView.delegate = self;
    }
    return _lockView;
}

@end
