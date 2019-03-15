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
    
    
    
    NSLog(@"_roomId = %@", _roomId);
    [self loadData:_roomId];
}

- (void)viewWillDisappear:(BOOL)animated{
    [mediaPlayer pause];
}

- (void)dealloc
{
    NSLog(@"VideoPlayViewController dealloc");
}

-(void)loadData:(NSString* )roomid{
    NSString *urlStr = @"http://193.112.65.251:8080/live/list/item";
    NSDictionary* parmeters = @{
                                @"roomid" : roomid,
                                @"slaveflag" : @1,
                                @"type" : @"json",
                                @"__plat" : @"android",
                                @"__version" : @"3.3.1.5978"
                                };
    [[NetworkingManager shareManager] POST:urlStr parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = responseObject;
        @try {
            int code = [[dict objectForKey:@"code"] intValue];
            if (code == 1) {
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                self->url = (NSString *)[dataDict valueForKey:@"videoUrl"];
                NSLog(@"请求成功 %@", self->url);
                [self->mediaPlayer open:self->url];
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
