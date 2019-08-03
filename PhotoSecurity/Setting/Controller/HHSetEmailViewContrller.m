//
//  HHSetEmailViewContrller.m
//  PhotoSecurity
//
//  Created by vanke on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHSetEmailViewContrller.h"

@interface HHSetEmailViewContrller ()

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;

@end

@implementation HHSetEmailViewContrller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"找回密码";
    self.emailTF.layer.cornerRadius = 8.0f;
    self.emailTF.layer.borderWidth = 0.5;
    self.emailTF.layer.borderColor = [UIColor colorWithHex:@"#999999"].CGColor;
    [self.okButton setBackgroundColor:[[UIColor alloc]
                                       initWithPatternImage:[UIImage imageNamed:@"Img_setPassword_bg.png"]]];
    self.okButton.layer.cornerRadius = 8.f;
    
}


- (IBAction)okButtonPressed:(id)sender {
 
    if(self.emailTF.text.length){

        HHAcountManager *account = [[HHAcountManager alloc] init];
        account.email = self.emailTF.text;
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Please enter email address", nil)];
    }
}


@end
