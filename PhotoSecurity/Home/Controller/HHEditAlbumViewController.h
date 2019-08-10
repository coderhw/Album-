//
//  HHEditAlbumViewController.h
//  PhotoSecurity
//
//  Created by Evan on 2019/8/10.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class HHAlbumModel;
typedef void(^HHChangeAblumThumbBlock)(HHAlbumModel *ablum);
typedef void(^HHDeleteAblumBlock)(void);

@interface HHEditAlbumViewController : HHBaseViewController

@property (nonatomic, strong) HHAlbumModel *album;
@property (nonatomic, copy) HHChangeAblumThumbBlock changeAlbumBlock;
@property (nonatomic, copy) HHDeleteAblumBlock deleteAlbumBlock;


@end

NS_ASSUME_NONNULL_END
