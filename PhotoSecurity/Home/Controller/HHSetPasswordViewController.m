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

@property (nonatomic, strong) PPLockView *lockView;

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
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
    
}

- (void)lockViewUnlockWithPasswd:(NSString *)passoword {
    
    NSLog(@"pass:%@", passoword);
    //已经设置过密码
    if([HHPasswordTool isSetPassword]){
        
        if(self.isChangePsd){
            [self setPasswordWithPassword:passoword];
        }else{
            
            BOOL isCorrectPsd = [HHPasswordTool verifyPassword:passoword];
            if(isCorrectPsd){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [HHProgressHUD showToast:NSLocalizedString(@"Password is wrong, please try again.", nil)];
            }
        }
    }else{
        [self setPasswordWithPassword:passoword];
    }
}

- (void)setPasswordWithPassword:(NSString *)password {
    
    //没设置过密码
    if(self.firstPsd.length){
        
        self.secondPsd = password;
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];

        if([self.firstPsd isEqualToString:self.secondPsd]){
            [HHPasswordTool storagePassword:self.secondPsd];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.isChangePsd){
                    
                    [HHProgressHUD showSuccessHUD:NSLocalizedString(@"Password is set success.", nil) toView:window];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [HHProgressHUD showSuccessHUD:NSLocalizedString(@"Password is set success.", nil) toView:window];
                }
            });
        }else{
            [self.lockView shake];
        }
    }else{
        
        self.lockView.tipsLabel.text = NSLocalizedString(@"Please set Gesture Password again", nil);
        self.firstPsd = password;
    }
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
