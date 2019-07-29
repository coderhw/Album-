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

@interface HHAlbumCollectionViewCell : UICollectionViewCell

- (void)configCellWithAlbumModel:(HHAlbumModel *)albumModel;

@end

NS_ASSUME_NONNULL_END
