//
//  HHSettingCell.m
//  PhotoSecurity
//
//  Created by vanke on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHSettingCell.h"
#import "HHNewSettingViewController.h"
@interface HHSettingCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatorView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UISwitch *passwordSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerY;
@property (weak, nonatomic) IBOutlet UIImageView *nextArrow;

@end

@implementation HHSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)configCellWith:(HHRowsModel *)model withRow:(NSInteger)row {
    
    [self.passwordSwitch setHidden:NO];
    NSInteger isOn = touchIDTypeEnabled() == 0 ? 0 : 1;
    [self.passwordSwitch setOn:isOn];
    [self.passwordSwitch addTarget:self
                                action:@selector(stateSwitchAction:)
                      forControlEvents:UIControlEventValueChanged];
    
    if(row == 0){
        self.passwordSwitch.hidden = NO;
    }else{
        self.passwordSwitch.hidden = YES;
    }
    
    if(row == 0 || row == 7){
        self.nextArrow.hidden = YES;
    }else{
        self.nextArrow.hidden = NO;
    }
    
    if(model.footerTips.length == 0){
        self.centerY.constant = 0;
    }else{
        self.centerY.constant = -8;
    }
    self.avatorView.image = [UIImage imageNamed:model.imageName];
    self.titleLabel.text = model.title;
    self.tipLabel.text = model.footerTips;
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)passwordSwith:(UISwitch *)sender {
    [self stateSwitchAction:sender];
}

- (void)stateSwitchAction:(UISwitch *)sender {
    if(self.passwordSwitchBlock){
        self.passwordSwitchBlock(sender);
    }
}

@end
