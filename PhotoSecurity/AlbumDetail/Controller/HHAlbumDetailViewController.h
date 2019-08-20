//
//  AppDelegate.m
//  PhotoSecurity
//
//  Created by huwen on 2017/3/1.
//  Copyright © 2017年 huwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TZImagePickerController.h>
@class HHAlbumModel;

typedef void(^HHChangeAblumThumbBlock)(HHAlbumModel *ablum);

@interface HHAlbumDetailViewController : UICollectionViewController<TZImagePickerControllerDelegate>

@property (nonatomic, strong) HHAlbumModel *album;
@property (nonatomic, assign) BOOL isChoseThumb; //是否选择封面
@property (nonatomic, copy) HHChangeAblumThumbBlock changeAlbumBlock;

@end
