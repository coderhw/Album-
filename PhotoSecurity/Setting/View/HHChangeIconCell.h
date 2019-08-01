//
//  HHChangeIconCell.h
//  PhotoSecurity
//
//  Created by Evan on 2019/8/1.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^HHChangeIconBlock)(UISwitch *sender);

@interface HHChangeIconCell : UITableViewCell

@property (nonatomic, copy) HHChangeIconBlock changeIconBlock;
- (void)configCellWithRow:(NSInteger)row selectRow:(NSInteger)selectRow;

@end

NS_ASSUME_NONNULL_END
