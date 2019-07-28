//
//  AppDelegate.m
//  PhotoSecurity
//
//  Created by xiaopin on 2017/3/1.
//  Copyright © 2017年 xiaopin. All rights reserved.
//

#import "AppDelegate.h"
#import "GHPopupEditView.h"
#import "HHSetPasswordViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


@interface AppDelegate ()
@property (nonatomic, strong) LAContext *context;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.backgroundColor = [UIColor whiteColor];
    checkPhotoRootDirectory();
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (0 == [userDefaults stringForKey:XPEncryptionPasswordRandomKey].length) {
        NSString *random = randomString(6);
        [userDefaults setObject:random forKey:XPEncryptionPasswordRandomKey];
        [userDefaults synchronize];
    }
    // 初始化数据库
    [[HHSQLiteManager sharedSQLiteManager] initializationDatabase];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([HHPasswordTool isSetPassword]) {
        for (UIView *subview in self.window.subviews) {
            if ([subview isKindOfClass:[GHPopupEditView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        self.context = [[LAContext alloc] init];
        
        UIViewController *rootVc = [self.window rootViewController];
        if (nil == rootVc.presentedViewController || ![rootVc.presentedViewController isKindOfClass:[HHSetPasswordViewController class]]) {
            [rootVc.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *unlockVc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HHSetPasswordViewController"];
            [rootVc presentViewController:unlockVc animated:NO completion:^{
                //如果设置了FaceID
                [weakSelf.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                 localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil)
                                           reply:^(BOOL success, NSError * _Nullable error) {
                                     
                                     if (!success) {
                                         return;
                                     }else{
                                         [unlockVc dismissViewControllerAnimated:YES completion:nil];
                                     }
                                 }];
            }];
        }
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
