//
//  XPAlbumModel.h
//  PhotoSecurity
//
//  Created by huwen on 2017/3/7.
//  Copyright © 2017年 huwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HHPhotoModel;

@interface HHAlbumModel : NSObject

/// 相册id
@property (nonatomic, assign) NSInteger albumid;
/// 相册目录
@property (nonatomic, copy) NSString *directory;
/// 相册名称
@property (nonatomic, copy) NSString *name;
/// 该相册下的图片数量
@property (nonatomic, assign) NSInteger count;
/// 排序id
@property (nonatomic, assign) NSInteger orderid;
/// 缩略图
@property (nonatomic, strong) HHPhotoModel *thumbImage;

@end
