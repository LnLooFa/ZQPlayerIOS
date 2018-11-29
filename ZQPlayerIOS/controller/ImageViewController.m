//
//  ImageViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/11/25.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImage *image1 = [UIImage imageNamed:@"goldImage"];
    _imageView1.image = image1;
    
    UIImage *image2 = [image1 stretchableImageWithLeftCapWidth:0 topCapHeight:image1.size.height*0.5];
    _imageView2.image = image2;
    
    UIImage *image3 = [image1 stretchableImageWithLeftCapWidth:image1.size.width*0.5 topCapHeight:0];
    _imageView3.image = image3;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
