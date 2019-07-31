//
//  TTBaseViewController.m
//  TTProject
//
//  Created by Evan on 16/8/29.
//  Copyright © 2016年 Evan. All rights reserved.
//

#import "XPNavigationController.h"
#import "HHBaseViewController.h"
#import "UIColor+XP.h"

@interface HHBaseViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton  *backButton;
@property (nonatomic, strong) UIImageView *shadowImage;
@property (nonatomic, strong) UILabel   *titleLabel;

@end

@implementation HHBaseViewController

- (void)dealloc {
    NSLog(@"%@控制器销毁", NSStringFromClass([self class]));
    if (_backButton) {
        [_backButton removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(self.navigationController.viewControllers.count == 1) {
        if(_backButton){
            [_backButton removeFromSuperview];
            _backButton = nil;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initBackButton];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem.backBarButtonItem setCustomView:[UIView new]];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithHex:@"#f0f0f0"];
    [self configNavigationBar];

}

- (void)initBackButton {
    if([self.navigationController.viewControllers count] == 2){
        [self.navigationController.navigationBar addSubview:self.backButton];
    }
    
    if (self.navigationController.viewControllers.count == 1) {
        if(self.backButton){
            [self.backButton removeFromSuperview];
            self.backButton = nil;
        }

    }
}


- (void)configNavigationBar {
    
    //改变状态栏颜色 导航栏字体 颜色
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTranslucent:NO];
    
    UIColor *barTintColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Img_setPassword_bg.png"]];
    [navigationBar setBarTintColor:barTintColor];
    
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    UIImage *backImage = [[UIImage imageNamed:@"icon-back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navigationBar setBackIndicatorImage:backImage];
    [navigationBar setBackIndicatorTransitionMaskImage:backImage];
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                           NSForegroundColorAttributeName: [UIColor whiteColor]};
    [barButtonItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    
    self.titleLabel.text = self.titleStr;
    self.navigationItem.titleView = self.titleLabel;
    
    // 隐藏导航栏下方的线
    [self hideBottomLineOnNavBar];
    
}

- (void)backButtonPressed:(UIButton *)sender {
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock();
    }
}

#pragma mark - Getter/Setter
- (UIButton *)backButton {
    
    if(!_backButton) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 44, 44);
        [backButton setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonPressed:)
             forControlEvents:UIControlEventTouchUpInside];
        _backButton = backButton;
        _backButton.hidden = _hideBackButton;
    }
    return _backButton;
}

- (void)setHideBackButton:(BOOL)hideBackButton{
    _hideBackButton = hideBackButton;
    self.backButton.hidden = hideBackButton;
}

- (void)setTitleStr:(NSString *)titleStr {
    if (titleStr.length > 12) {
        titleStr = [titleStr substringToIndex:12];
        _titleStr = [NSString stringWithFormat:@"%@...",titleStr];
    }else {
        _titleStr = titleStr;
    }
    self.titleLabel.textColor = self.titleColor?self.titleColor:[UIColor whiteColor];
    self.titleLabel.text = _titleStr;
}

#pragma mark -遍历导航栏的所有子视图
NSArray *allSubviews(UIView *aView) {
    NSArray *results = [aView subviews];
    for (UIView *eachView in aView.subviews)
        {
        NSArray *subviews = allSubviews(eachView);
        if (subviews)
            results = [results arrayByAddingObjectsFromArray:subviews];
        }
    return results;
}

// 隐藏导航栏下方的线
- (void)hideBottomLineOnNavBar {
    NSArray *subViews = allSubviews(self.navigationController.navigationBar);
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[UIImageView class]] && view.bounds.size.height<1) {
                //实践后发现系统的横线高度为0.333
            self.shadowImage = (UIImageView *)view;
        }
    }
    self.shadowImage.hidden = YES;
}

- (void)setHideNavBottomLine:(BOOL)hideNavBottomLine{
    self.shadowImage.hidden = hideNavBottomLine;
}
- (void)setNavColor:(UIColor *)navColor {
    self.navigationController.navigationBar.barTintColor = navColor;
}

- (void)setTitleColor:(UIColor *)titleColor {
    if(!titleColor){
        titleColor = [UIColor whiteColor];
    }
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:titleColor,
                              NSFontAttributeName:BFONT(16)}];

}

- (void)setTitleFont:(UIFont *)titleFont {
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSFontAttributeName:titleFont}];
}


#pragma mark - Getter/Setter Methods
- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_WIDH*0.6, 44)];
        _titleLabel.font = kFONT(kTitleName_PingFang_M, 18);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = RGB(51, 51, 51);
    }
    return _titleLabel;
}

@end

