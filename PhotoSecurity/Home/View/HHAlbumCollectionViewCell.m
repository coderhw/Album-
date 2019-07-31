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
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation HHAlbumCollectionViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];

}

- (void)configCellWithAlbumModel:(HHAlbumModel *)album isEdit:(BOOL)isEdit {
    
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
    if(!album.count){
        self.avatorView.contentMode = UIViewContentModeCenter;
    }else{
        self.avatorView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if(isEdit){
        self.deleteButton.hidden = NO;
    }else{
        self.deleteButton.hidden = YES;
    }

}

- (IBAction)deleButtonPressed:(id)sender {
    if(self.deleblock){
        self.deleblock();
    }
}

@end
