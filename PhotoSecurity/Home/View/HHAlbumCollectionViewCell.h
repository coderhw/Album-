//
//  HHAlbumCollectionViewCell.h
//  PhotoSecurity
//
//  Created by vanke on 2019/7/29.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHAlbumModel.h"
#import "HHPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HHDeleAlbumBlock)(void);
typedef void(^HHEditAlbumBlock)(void);

@interface HHAlbumCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) HHDeleAlbumBlock deleblock;
@property (nonatomic, copy) HHEditAlbumBlock editAlbumblock;
- (void)configCellWithAlbumModel:(HHAlbumModel *)album
                          isEdit:(BOOL)isEdit;

@end

NS_ASSUME_NONNULL_END
