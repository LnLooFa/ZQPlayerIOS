//
//  FFmpegTestViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/14.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "FFmpegTestViewController.h"
#import <libavformat/avformat.h>

@interface FFmpegTestViewController ()

@end

@implementation FFmpegTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    av_register_all();
    avcodec_register_all();
    avformat_network_init();
    AVFormatContext *avFormatContext = avformat_alloc_context();
    
    NSString *url = @"http://vjs.zencdn.net/v/oceans.mp4";
    if (avformat_open_input(&avFormatContext, [url UTF8String], NULL, NULL) != 0){
        av_log(NULL, AV_LOG_ERROR, "Couldn't open file");
    }
    
    if (avformat_find_stream_info(avFormatContext, NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information");
    } else {
        av_dump_format(avFormatContext, 0, [url cStringUsingEncoding:NSUTF8StringEncoding], NO);
    }
    
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
