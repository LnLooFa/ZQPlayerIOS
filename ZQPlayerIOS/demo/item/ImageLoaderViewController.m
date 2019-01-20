//
//  ImageLoaderViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/8.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ImageLoaderViewController.h"
#import <UIImageView+WebCache.h>

@interface ImageLoaderViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSD;

@end

@implementation ImageLoaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    NSURL *photourl = [NSURL URLWithString:@"http://img4.imgtn.bdimg.com/it/u=967395617,3601302195&fm=26&gp=0.jpg"];
//    //url请求实在UI主线程中进行的
//    UIImage *images = [UIImage imageWithData:[NSData dataWithContentsOfURL:photourl]];//通过网络url获取uiimage
//    self.imageView.image = images;
    [self downLoadImage];
    
    [self.imageViewSD sd_setImageWithURL:photourl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        NSLog(@"错误信息:%@",error);
        
    }];
}


//下载图片
- (void)downLoadImage{
    //请求图片资源
    NSURL *url=[NSURL URLWithString:@"http://pic7.nipic.com/20100515/2001785_115623014419_2.jpg"];
    //将资源转换为二进制
    NSData *data=[NSData dataWithContentsOfURL:url];
    NSLog(@"downLoadImage:%@",[NSThread currentThread]);//在子线程中下载图片
    //在主线程更新UI
    [self performSelectorOnMainThread:@selector(updateImage:) withObject:data waitUntilDone:YES];
    
}

//更新imageView
- (void)updateImage:(NSData *)data{
    NSLog(@"updateImage:%@",[NSThread currentThread]);//在主线程中更新UI
    //将二进制数据转换为图片
    UIImage *image=[UIImage imageWithData:data];
    //设置image
    self.imageView.image=image;
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
