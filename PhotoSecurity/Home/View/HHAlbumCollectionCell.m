//
//  HHAlbumCollectionCell.m
//  PhotoSecurity
//
//  Created by vanke on 2019/7/29.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHAlbumCollectionCell.h"

@interface HHAlbumCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatorView;
@property (weak, nonatomic) IBOutlet UILabel *albumName;
@property (weak, nonatomic) IBOutlet UILabel *photoCount;


@end

@implementation HHAlbumCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)configCellWithAlbumModel{
    
    self.avatorView.cornerRadius = 10.0;
    self.avatorView.clipsToBounds = YES;
}

@end
