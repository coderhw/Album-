//
//  HHBlurAlertView.h
//  PhotoSecurity
//
//  Created by vanke on 2019/7/31.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHBlurAlertActionBlock)(NSInteger index, NSString *title);

@interface HHBlurAlertView : UIView

@property (nonatomic, copy) HHBlurAlertActionBlock alertActionBlock;

+(instancetype)blurAlertView;

- (void)show;

@end

NS_ASSUME_NONNULL_END
