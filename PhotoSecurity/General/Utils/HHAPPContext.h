//
//  VKUserInfo.h
//  MeiFang
//
//  Created by Evan on 2017/3/17.
//  Copyright © 2017年 Vanke.com All rights reserved.
//
/*
 * * 放置App信息eg:是否版本更新，是否已经登录......
 */

#import <Foundation/Foundation.h>

@interface HHAPPContext : NSObject

//登录状态
@property (nonatomic, assign) BOOL isShowPassword;

+ (instancetype)sharedAppContext;



@end




