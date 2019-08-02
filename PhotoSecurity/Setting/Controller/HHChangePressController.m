//
//  HHChangePressController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/2.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHChangePressController.h"

@interface HHChangePressController ()
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSilder;

@end

@implementation HHChangePressController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSString *pressRate =  [[NSUserDefaults standardUserDefaults] valueForKey:@"KPressRateKey"];
    if( [pressRate floatValue] == 0 || pressRate == nil){
        self.progressSilder.value = 1;
    }else{
        self.progressSilder.value = [pressRate floatValue];
    }
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f", self.progressSilder.value];

    [self.progressSilder addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChanged:(UISlider *)slider {
   
    self.progressLabel.text = [NSString stringWithFormat:@"%f", slider.value];

}
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    NSString *pressRate = [NSString stringWithFormat:@"%f", self.progressSilder.value];
    [[NSUserDefaults standardUserDefaults] setValue:pressRate forKey:@"KPressRateKey"];

}

@end
