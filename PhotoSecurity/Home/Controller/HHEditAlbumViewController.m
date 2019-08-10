//
//  HHEditAlbumViewController.m
//  PhotoSecurity
//
//  Created by Evan on 2019/8/10.
//  Copyright © 2019 xiaopin. All rights reserved.
//

#import "HHEditAlbumViewController.h"
#import "HHAlbumModel.h"
#import "HHPhotoModel.h"
#import "HHAlbumDetailViewController.h"

@interface HHEditAlbumViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *albumNameTF;
@property (weak, nonatomic) IBOutlet UIButton *avatorView;
@property (weak, nonatomic) IBOutlet UIButton *deleAlbumButton;


@end

@implementation HHEditAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"编辑相册", nil);
    
    self.albumNameTF.delegate = self;
    self.albumNameTF.placeholder = self.album.name?self.album.name:@"默认相册";
    [self.albumNameTF addTarget:self action:@selector(albumNameTFValueDidChanged:) forControlEvents:UIControlEventEditingChanged];
    
    self.avatorView.layer.cornerRadius = 2.0f;
    self.avatorView.clipsToBounds = YES;
    
    [self configAvatorButton];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    if(self.changeAlbumBlock && self.album){
        self.changeAlbumBlock(self.album);
    }
}

- (IBAction)avatorButtonPressed:(id)sender {
    
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HHAlbumDetailViewController *detailVC = [mainBoard instantiateViewControllerWithIdentifier:@"HHAlbumDetailViewController"];
    detailVC.album = self.album;
    detailVC.isChoseThumb = YES;
    
    detailVC.changeAlbumBlock = ^(HHAlbumModel *ablum) {
        self.album = ablum;
        [self configAvatorButton];
    };
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)deleButtonPressed:(id)sender {
    
    NSString *title = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Delete", nil), self.album.name];
    NSString *message = NSLocalizedString(@"Are you sure you want to delete the album? All the pictures under the album will be deleted.", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Album", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
            if(self.deleteAlbumBlock){
                self.deleteAlbumBlock();
                self.album = nil;
                [self.navigationController popViewControllerAnimated:YES];
            }
        
        }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];   
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)configAvatorButton {
    
    UIImage *image = nil;
    if (self.album.count && self.album.thumbImage) {
        NSString *path = [NSString stringWithFormat:@"%@/%@/%@/%@",
                          photoRootDirectory(),
                          self.album.directory,XPThumbDirectoryNameKey,
                          self.album.thumbImage.filename];
        image = [[UIImage alloc] initWithContentsOfFile:path];
    }
    [self.avatorView setImage:image ?: [UIImage imageNamed:@"album-placeholder"] forState:UIControlStateNormal];
}

#pragma mark - UITextField Delegate
- (void)albumNameTFValueDidChanged:(UITextField *)tf {
    NSLog(@"%s", __func__);
    if(tf.text.length){
        self.album.name = tf.text;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
