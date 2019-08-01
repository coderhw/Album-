//
//  HHSettingCell.h
//  PhotoSecurity
//
//  Created by vanke on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class HHRowsModel;
typedef void(^HHPassowordSwitchBlock)(UISwitch *sender);

@interface HHSettingCell : UITableViewCell
@property (nonatomic, copy) HHPassowordSwitchBlock passwordSwitchBlock;
- (void)configCellWith:(HHRowsModel *)model withRow:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
