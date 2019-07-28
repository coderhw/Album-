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

@end

@implementation HHSetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGTH)];
    [bg setImage:[UIImage imageNamed:@"Img_setPassword_bg.png"]];
    [self.view addSubview:bg];
    
    PPLockView *lockView = [[PPLockView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGTH)];
    lockView.delegate = self;
    [self.view addSubview:lockView];
    
    if([HHPasswordTool isSetPassword]){
        lockView.tipsLabel.hidden = YES;
    }else{
        lockView.tipsLabel.hidden = NO;
    }
    
}

- (void)lockViewUnlockWithPasswd:(NSString *)passoword {
    
    NSLog(@"pass:%@", passoword);
    
    //已经设置过密码
    if([HHPasswordTool isSetPassword]){
        
        BOOL isCorrectPsd = [HHPasswordTool verifyPassword:passoword];
        if(isCorrectPsd){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            
            [HHProgressHUD showToast:NSLocalizedString(@"Password is wrong, please try again.", nil)];
        }
        
    }else{
        
        //没设置过密码
        if(self.firstPsd.length){
            
            self.secondPsd = passoword;
            if([self.firstPsd isEqualToString:self.secondPsd]){
               
                [HHPasswordTool storagePassword:self.secondPsd];
                NSLog(@"设置了手势密码");
                
                BOOL isSetPsd = [HHPasswordTool isSetPassword];
                NSLog(@"isSetPsd:%d", isSetPsd);
                
                BOOL isCorrectPsd = [HHPasswordTool verifyPassword:@"01258"];
                NSLog(@"isCorrectPsd:%d", isCorrectPsd);
            }
        }else{
            self.firstPsd = passoword;
        }
    }
}


@end
