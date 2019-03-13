//
//  GlViewTestViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "GlViewTestViewController.h"
#import "OpenGlView.h"
@interface GlViewTestViewController (){
     OpenGlView* v;
//    ZQPlayerFrameVideo* frame;
}

@end

@implementation GlViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)viewDidLayoutSubviews{
    
    v = [[OpenGlView alloc] initWithFrame:CGRectMake(100,100,200,200)];
    [self.view addSubview:v];
//    __weak typeof(self)weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        if (!strongSelf) {
//            return;
//        }
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"scenery" ofType:@"jpg"];
//        UIImage *image = [UIImage imageWithContentsOfFile:path];
//        NSLog(@"image.size.width = %f, image.size.height = %f", image.size.width, image.size.height);
//
//        GLubyte* imageData = malloc(image.size.width * image.size.height * 4);
//        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
//        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
//        CGContextRelease(imageContext);
//
//        ZQPlayerFrameVideo* frame = [[ZQPlayerFrameVideo alloc] init];
//        frame.width = image.size.width;
//        frame.height = image.size.height;
//        frame.data = [NSData dataWithBytes:imageData length:image.size.width * image.size.height * 4];
//        frame.format = GL_RGBA;
//        [strongSelf->v render:frame];
//    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"scenery" ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        NSLog(@"image.size.width = %f, image.size.height = %f", image.size.width, image.size.height);

        GLubyte* imageData = malloc(image.size.width * image.size.height * 4);
        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        CGContextRelease(imageContext);

        ZQPlayerFrameVideo* frame = [[ZQPlayerFrameVideo alloc] init];
        frame.width = image.size.width;
        frame.height = image.size.height;
        frame.data = [NSData dataWithBytes:imageData length:image.size.width * image.size.height * 4];
        frame.format = GL_RGBA;
        [self->v render:frame];
    });
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
