//
//  HHNewSettingViewController.h
//  PhotoSecurity
//
//  Created by vanke on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HHNewSettingViewController : HHBaseViewController

@end

NS_ASSUME_NONNULL_END

@interface HHRowsModel : NSObject

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *footerTips;


@end
