//
//  VideoPlayViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/26.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "VideoPlayViewController.h"
#import "MediaPlayer.h"
#import "NetworkingManager.h"
@interface VideoPlayViewController (){
    MediaPlayer *mediaPlayer;
    NSString *url;
}

@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:false animated:false];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;//导航栏不遮挡
    
    mediaPlayer = [[MediaPlayer alloc] init];
    [self.view addSubview:mediaPlayer.openGlView];
    [mediaPlayer.openGlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kScreenWidth /16 * 9);
    }];
    
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [mediaPlayer pause];
}

- (void)dealloc
{
    NSLog(@"VideoPlayViewController dealloc");
}

-(void)loadData{
    NSDictionary* parmeters = @{
                                @"live_id" : self.live_id,
                                @"live_type" : self.live_type,
                                @"game_type" : self.game_type
                                };
    [[NetworkingManager shareManager] POST:kLiveItemDetailUrl parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = responseObject;
        @try {
            int code = [[dict objectForKey:@"code"] intValue];
            if (code == 1) {
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                if ([[dataDict allKeys] containsObject:@"stream_list"]) {
                    // contains key
                    NSMutableArray * streamList = [dataDict objectForKey:@"stream_list"];
                    if(streamList.count > 0){
                        NSDictionary * streamItem = streamList[0];
                        self->url = (NSString *)[streamItem valueForKey:@"url"];
                        NSLog(@"请求成功 %@", self->url);
                        [self->mediaPlayer open:self->url];
                    }else{
                        NSLog(@"没有直播源");
                    }
                }else{
                    NSLog(@"没有直播源");
                }
            }else {
                NSString *message = [dict objectForKey:@"msg"];
                NSLog(@"请求失败 %@",message);
            }
        } @catch (NSException *exception) {
            NSLog(@"获取验证码报错 %@",exception);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败  %@ ",error);
    
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
