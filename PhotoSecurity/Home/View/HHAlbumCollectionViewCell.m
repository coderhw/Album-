//
//  HHAlbumCollectionViewCell.m
//  PhotoSecurity
//
//  Created by vanke on 2019/7/29.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHAlbumCollectionViewCell.h"

@interface HHAlbumCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatorView;
@property (weak, nonatomic) IBOutlet UILabel *avatorName;
@property (weak, nonatomic) IBOutlet UILabel *avatorCount;

@end

@implementation HHAlbumCollectionViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];

}

- (void)configCellWithAlbumModel:(HHAlbumModel *)album {
    
    UIImage *image = nil;
    if (album.count && album.thumbImage) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@",
                          photoRootDirectory(),
                          album.directory,XPThumbDirectoryNameKey,
                          album.thumbImage.filename];
        image = [[UIImage alloc] initWithContentsOfFile:path];
    }
    self.avatorName.text = album.name;
    self.avatorCount.text = [NSString stringWithFormat:@"%@张", [NSString stringWithFormat:@"%ld", album.count]];
    self.avatorView.image = image ?: [UIImage imageNamed:@"album-placeholder"];
//    self.avatorView.layer.masksToBounds = YES;
//    self.avatorView.layer.cornerRadius = 5.0f;
}

@end
