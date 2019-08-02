//
//  HHChangeIconCell.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHChangeIconCell.h"

@interface HHChangeIconCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatorView;
@property (weak, nonatomic) IBOutlet UISwitch *iconSwitch;

@end

@implementation HHChangeIconCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (void)configCellWithRow:(NSInteger)row selectRow:(NSInteger)selectRow; {
    
    NSString *imageName = nil;
    switch (row) {
        case 0:
        {
            imageName = @"IconRainbow.png";
        }
            break;
        case 1:
        {
            imageName = @"IconDrama.png";
        }
            break;
        case 2:
        {
            imageName = @"IconPre.png";
        }
            break;
        case 3:
        {
            imageName = @"IconDefalt.png";
        }
        default:
            break;
    }
    
    [self.avatorView setImage:[UIImage imageNamed:imageName]];
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

@end
