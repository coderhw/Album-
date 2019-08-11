//
//  HHSetPasswordViewController.h
//  PhotoSecurity
//
//  Created by Evan on 2019/7/25.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHUnlockBlock)(void);
@interface HHSetPasswordViewController : HHBaseViewController

@property (nonatomic, assign) BOOL isChangePsd;
@property (nonatomic, copy) HHUnlockBlock unlockBlock;


- (void)showTips;

@end

NS_ASSUME_NONNULL_END
