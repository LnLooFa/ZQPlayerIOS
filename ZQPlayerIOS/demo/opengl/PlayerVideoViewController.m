//
//  PlayerVideoViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/21.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "PlayerVideoViewController.h"
#import <libavformat/avformat.h>
#import <libavutil/imgutils.h>
#import <libswscale/swscale.h>
#import <libavutil/eval.h>
#import <libavutil/display.h>
#import "MediaPlayer.h"

@interface PlayerVideoViewController (){
    MediaPlayer *mediaPlayer;
}

@end

@implementation PlayerVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mediaPlayer = [[MediaPlayer alloc] init];
    mediaPlayer.openGlView.frame = CGRectMake(0,0,320,180);
    [self.view addSubview:mediaPlayer.openGlView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"gao_bai_qi_qiu.mp4" ofType:nil];
    [mediaPlayer open:urlStr];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self->mediaPlayer pause];
}

- (void)dealloc
{
    NSLog(@"ziq player dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
