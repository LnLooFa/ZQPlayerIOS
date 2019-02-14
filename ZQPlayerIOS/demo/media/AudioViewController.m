//
//  AudioViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/27.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "AudioViewController.h"
// 导入系统框架
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface AudioViewController ()<AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *playProgress;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer1;//播放器
@property (weak ,nonatomic) NSTimer *timer;//进度更新定时器
@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)playYinXiao:(id)sender {
    NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"send" ofType:@"caf"];
    NSLog(@"%@", soundPath);
    NSURL *fileUrl = [NSURL URLWithString:soundPath];    
    
//    NSURL *fileUrl = [NSURL URLWithString:@"/System/Library/Audio/UISounds/send.caf"];
    //注意 当前是在 xcdoe 虚拟机上跑，查找的是mac 上的目录，不是虚拟手机上的。在对应位置加文件
    
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

/**
 *  播放完成回调函数
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}



- (IBAction)initMusic1:(id)sender {
    
    NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"gang_hao_yu_jian_ni" ofType:@"mp3"];
    NSURL *url=[NSURL fileURLWithPath:soundPath];
    NSError *error=nil;
    
    //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
    _audioPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    //设置播放器属性
    _audioPlayer1.numberOfLoops=0;//设置为0不循环
    //    audioPlayer.volume = 0.5;
    _audioPlayer1.delegate=self;
    //预加载资源
    if ([_audioPlayer1 prepareToPlay]) {//加载音频文件到缓存
        NSLog(@"准备完毕");
        
    }
//    [_audioPlayer play];//注意 如果AVAudioPlayer 是局部变量的话，会被回收掉。
    
    //设置后台播放模式
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [audioSession setActive:YES error:nil];
}

- (IBAction)playOrPause1:(UIButton *)sender {
    if(sender.tag){
        sender.tag=0;
        [sender setTitle:@"播放" forState:UIControlStateNormal];
        [self pause1];
    }else{
        sender.tag=1;
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self play1];
    }
}

-(void)play1{
    if (![self.audioPlayer1 isPlaying]) {
        [self.audioPlayer1 play];
        self.timer.fireDate=[NSDate distantPast];//恢复定时器
    }
}

-(void)pause1{
    if ([self.audioPlayer1 isPlaying]) {
        [self.audioPlayer1 pause];
        self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        
    }
}

-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return _timer;
}

-(void)updateProgress{
    float progress= self.audioPlayer1.currentTime /self.audioPlayer1.duration;
    [self.playProgress setProgress:progress animated:true];
}

#pragma mark - 播放器代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"音乐播放完成...");
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
