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
    [self.iconSwitch addTarget:self action:@selector(iconSwitchStateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)configCellWithRow:(NSInteger)row selectRow:(NSInteger)selectRow; {
    
    NSString *imageName = nil;
    switch (row) {
        case 0:
        {
            imageName = @"icon_rainbow.png";
        }
            break;
        case 1:
        {
            imageName = @"icon_ drama.png";
        }
            break;
        case 2:
        {
            imageName = @"icon_pre.png";
        }
        default:
            break;
    }
    
    [self.avatorView setImage:[UIImage imageNamed:imageName]];
}

- (void)iconSwitchStateChanged:(UISwitch *)sender {
    
    if(self.changeIconBlock){
        self.changeIconBlock(sender);
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

@end
