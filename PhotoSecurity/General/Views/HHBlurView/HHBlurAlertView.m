//
//  HHBlurAlertView.m
//  PhotoSecurity
//
//  Created by vanke on 2019/7/31.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHBlurAlertView.h"

@interface HHBlurAlertView ()

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (nonatomic, strong) UIControl *background;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;


@end

@implementation HHBlurAlertView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.tipLabel.text = NSLocalizedString(@"Create a new album", nil);
    [self.background addTarget:self action:@selector(dismiss)
              forControlEvents:UIControlEventTouchUpInside];
    
    self.nameTF.layer.borderWidth = 0.05;
    self.nameTF.layer.borderColor = [UIColor colorWithHex:@"#333333"].CGColor;
    self.nameTF.layer.cornerRadius = 20.0f;
    self.nameTF.placeholder = NSLocalizedString(@"Please enter the album name", nil);
    
    self.cancelButton.layer.borderWidth = 0.05;
    self.cancelButton.layer.borderColor = [UIColor colorWithHex:@"#333333"].CGColor;
    self.cancelButton.layer.cornerRadius = 20.0f;
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    
    self.okButton.layer.borderWidth = 0.05;
    self.okButton.layer.borderColor = [UIColor colorWithHex:@"#333333"].CGColor;
    self.okButton.layer.cornerRadius = 20.0f;
    [self.okButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.nameTF.tintColor = [UIColor colorWithHex:@"#333333"];

}

+ (instancetype)blurAlertView {
    
    HHBlurAlertView *blurView =  [[[NSBundle mainBundle] loadNibNamed:@"HHBlurAlertView" owner:nil options:nil] firstObject];
    blurView.frame = CGRectMake(0, 0, 268, 248);
    blurView.layer.cornerRadius = 10.0f;
    blurView.layer.masksToBounds = YES;
    return blurView;
}

- (void)show {
    
    self.background = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, APP_WIDH, APP_HIGH)];
    self.background.alpha = 0.1;
    self.background.backgroundColor = [UIColor whiteColor];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.background];
    self.alpha = 0.0;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    self.center = CGPointMake(self.superview.center.x, self.superview.center.y - 100);
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
    [self.nameTF becomeFirstResponder];

}

- (void)dismiss {
    
    [self.background removeFromSuperview];
    _background = nil;
    [self removeFromSuperview];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismiss];
    if(self.alertActionBlock){
        self.alertActionBlock(2, @"");
    }
}


- (IBAction)okButtonPressed:(id)sender {
    
    [self dismiss];
    if(self.alertActionBlock){
        self.alertActionBlock(1, self.nameTF.text.length ? self.nameTF.text : NSLocalizedString(@"Default Album", nil));
    }
}



@end
