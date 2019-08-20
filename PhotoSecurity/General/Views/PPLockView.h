//
//  PPLockView.h
//  GestureLock
//
//  Created by 王鹏 on 12-9-28.
//  Copyright (c) 2012年 pengjay.cn@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PPLockViewDelegate;

typedef void(^HHTipBlock)(void);
@interface PPLockView : UIView {
    
	NSMutableArray *_selectedPointArray;
	CGPoint currentPoint;
	NSMutableString *_passwd;
}

@property (nonatomic, assign) id <PPLockViewDelegate> delegate;
@property (nonatomic, strong) UILabel   *tipsLabel;
@property (nonatomic, strong) UIButton  *tipButton;
@property (nonatomic, copy) HHTipBlock tipBlock;


- (instancetype)initWithFrame:(CGRect)frame;

@end

@protocol PPLockViewDelegate <NSObject>

@optional

- (void)lockViewUnlockWithPasswd:(NSString *)pass;

@end
