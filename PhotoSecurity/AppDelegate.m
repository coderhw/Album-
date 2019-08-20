//
//  AppDelegate.m
//  PhotoSecurity
//
//  Created by huwen on 2017/3/1.
//  Copyright © 2017年 huwen. All rights reserved.
//

#import "AppDelegate.h"
#import "GHPopupEditView.h"
#import "HHSetPasswordViewController.h"
#import "HHNewHomeViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <UMCommon/UMCommon.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "NSDate+Category.h"

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

    //
    NSLog(@"Home:%@", NSHomeDirectory());
    
    // 初始化数据库
    [[HHSQLiteManager sharedSQLiteManager] initializationDatabase];
    [UMConfigure initWithAppkey:@"5d4d35ef3fc195132b00044c" channel:@"App Store"];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    AppContext.isShowPassword = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:HHLastUsedDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([HHPasswordTool isSetPassword]) {
        for (UIView *subview in self.window.subviews) {
            if ([subview isKindOfClass:[GHPopupEditView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        UIViewController *rootVc = [self.window rootViewController];
        if (nil == rootVc.presentedViewController || ![rootVc.presentedViewController isKindOfClass:[HHSetPasswordViewController class]]) {
            
            [rootVc.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HHSetPasswordViewController *unlockVc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HHSetPasswordViewController"];
            [unlockVc showTips];
            AppContext.isShowPassword = YES;
            [rootVc presentViewController:unlockVc animated:YES completion:^{
                if(touchIDTypeEnabled()){
                    //如果设置了FaceID
                    self.context = [[LAContext alloc] init];
                    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                 localizedReason:NSLocalizedString(@"You can use the Touch ID to verify the fingerprint quickly to complete the unlock application", nil)
                                           reply:^(BOOL success, NSError * _Nullable error) {
                                               
                                               if (!success) {
                                                   return;
                                               }else{
                                                   [unlockVc dismissViewControllerAnimated:YES completion:^{
                                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                           //处理解锁后的事情
                                                           [self saveCurrentLoginTime];
                                                       });
                                                   }];
                                               }
                                           }];
                }
                
            }];
        }
    }
}

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

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    AppContext.isShowPassword = NO;
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:HHLastUsedDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
