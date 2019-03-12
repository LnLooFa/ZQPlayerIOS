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
#import "ZQPlayerFrameVideoRGB.h"
#import "ZQPlayerFrameAudio.h"
#import "OpenGlView.h"
#import "AudioUnitManager.h"
#import "Decoder.h"
static BOOL S_IS_PlAYING;
@interface PlayerVideoViewController (){
    
    AudioUnitManager *mAudioUnitManager;
    Decoder *mDecoder;
    
    BOOL mIsPlaying;
    NSThread *mFrameReaderThread;
    
    //缓存判断
    double mMinBufferDuration;
    double mMaxBufferDuration;
    double mBufferedDuration;//当前缓存
    //video
    OpenGlView* openGlView;
    NSMutableArray *vframes;
    dispatch_semaphore_t vFramesLock;
    //audio
    NSMutableArray *aframes;
    dispatch_semaphore_t aFramesLock;
    ZQPlayerFrameAudio *playingAudioFrame;
    
    
    NSUInteger playingAudioFrameDataPosition;
    
    double mediaPosition;

    double mediaSyncTime;
    double mediaSyncPosition;
}

@end

@implementation PlayerVideoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        S_IS_PlAYING = NO;
        mIsPlaying = NO;
        mMinBufferDuration = 2;
        mMaxBufferDuration = 5;
        mBufferedDuration = 0;
        
        vframes = [NSMutableArray arrayWithCapacity:128];
        vFramesLock = dispatch_semaphore_create(1);
        aframes = [NSMutableArray arrayWithCapacity:128];
        aFramesLock = dispatch_semaphore_create(1);
        
        playingAudioFrame = nil;
        playingAudioFrameDataPosition = 0;
        mediaPosition = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    openGlView = [[OpenGlView alloc] initWithFrame:CGRectMake(0,0,320,180)];
    [self.view addSubview:openGlView];
    [self initPlayer];
}

- (void)viewWillDisappear:(BOOL)animated{
    S_IS_PlAYING = FALSE;//用静态变量 ，不然为了解除强引用，viewWillDisappear时候解除
    mIsPlaying = FALSE;
    if(mFrameReaderThread != nil){
        mFrameReaderThread = nil;
    }
    [mAudioUnitManager pause];
}

- (void)dealloc
{
    NSLog(@"ziq player dealloc");
}


-(void)initPlayer{
    mAudioUnitManager = [[AudioUnitManager alloc] init];
    mDecoder = [[Decoder alloc] init];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if ([strongSelf->mAudioUnitManager open]) {
            NSLog(@"mAudioUnitManager open 成功");
            [strongSelf->mDecoder setAudioChannels:[strongSelf->mAudioUnitManager channels]];
            [strongSelf->mDecoder setAudioSampleRate:[strongSelf->mAudioUnitManager sampleRate]];
        } else {
            NSLog(@"mAudioUnitManager open 失败");
        }
        
        //初始化
        NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"gao_bai_qi_qiu.mp4" ofType:nil];
        if(![strongSelf->mDecoder open:urlStr]){
            return;
        }
        
        S_IS_PlAYING = TRUE;
        strongSelf->mIsPlaying = TRUE;
        //解码线程
        [strongSelf startFrameReaderThread];
        //渲染声音
        __weak typeof(strongSelf)ws = strongSelf;
        strongSelf->mAudioUnitManager.frameReaderBlock = ^(float *data, UInt32 frames, UInt32 channels){
            [ws readAudioFrame:data frames:frames channels:channels];
        };
        [strongSelf->mAudioUnitManager play];
        //渲染视频
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf render];
        });
        
    });
}

- (void)startFrameReaderThread {
    if (mFrameReaderThread == nil) {
        mFrameReaderThread = [[NSThread alloc] initWithTarget:self selector:@selector(readFrameRunnable) object:nil];
        [mFrameReaderThread start];
    }
}

-(void)readFrameRunnable{
    @autoreleasepool {
        while (self->mIsPlaying && ![self->mDecoder isEndOfFile]) {
            if(self->mBufferedDuration < self->mMaxBufferDuration){
                //读取音视频帧
                NSArray *fs = [self->mDecoder readFrames];
                if (fs == nil) { break; }
                if (fs.count == 0) { continue; }
                for (ZQPlayerFrame *f in fs) {
                    if (f.type == ZQPlayerFrameTypeVideo) {
                        [self->vframes addObject:f];
                        self->mBufferedDuration += f.duration;//音频 同步
                    }else if (f.type == ZQPlayerFrameTypeAudio) {
                        [self->aframes addObject:f];
                    }
                }
                NSLog(@"ziq 读取 frame = %lu, aframes = %lu", (unsigned long)fs.count, self->aframes.count);
            }else{
                //空运转会耗费cpu
                [NSThread sleepForTimeInterval:1.5];
            }
        }
        mFrameReaderThread = nil;
    }
}


- (void)render {
    if (!mIsPlaying) return;
    
    if (self->vframes.count <= 0) {
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf render];
        });
        return;
    }
    
    NSLog(@"ziq 渲染视频 vframe size = %lu", (unsigned long)self->vframes.count);
    ZQPlayerFrameVideoRGB *frame = self->vframes[0];
    [self->vframes removeObjectAtIndex:0];
    self->mediaPosition = frame.position;
    self->mBufferedDuration -= frame.duration;
    
    NSLog(@"ziq1 渲染视频---- ");
    [self->openGlView render:frame];
    
    double syncTime = [self syncTime];
    NSTimeInterval t = MAX(frame.duration + syncTime, 0.01);
    NSLog(@"ziq1 渲染视频mediaPosition=%f, t=%f", self->mediaPosition, t);
    
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf render];
    });
}

- (double)syncTime {
    const double now = [NSDate timeIntervalSinceReferenceDate];
    
    if (mediaSyncTime == 0) {
        mediaSyncTime = now;
        mediaSyncPosition = mediaPosition;
        return 0;
    }
    
    double dp = mediaPosition - mediaSyncPosition;
    double dt = now - mediaSyncTime;
    double sync = dp - dt;
    NSLog(@"ziq1 %f = %f - %f, %f = %f - %f, %f", dp,mediaPosition,mediaSyncPosition,dt,now,mediaSyncTime, sync);
    if (sync > 1 || sync < -1) {
        sync = 0;
        mediaSyncTime = 0;
    }
    
    return sync;
}



- (void)readAudioFrame:(float *)data frames:(UInt32)frames channels:(UInt32)channels {
    NSLog(@"ziq 渲染音频 aframe size = %lu", (unsigned long)self->aframes.count);
    if (!mIsPlaying) return;
    while(frames > 0) {
        @autoreleasepool {
            if (self->playingAudioFrame == nil) {
                {
                    if (self->aframes.count <= 0) {
                        memset(data, 0, frames * channels * sizeof(float));
                        return;
                    }
                    
                    long timeout = dispatch_semaphore_wait(self->aFramesLock, DISPATCH_TIME_NOW);
                    if (timeout == 0) {
                        ZQPlayerFrameAudio *frame = self->aframes[0];
                        const double dt = self->mediaPosition - frame.position;
                        if (dt < -0.1) { // audio is faster than video, silence
                            memset(data, 0, frames * channels * sizeof(float));
                            dispatch_semaphore_signal(self->aFramesLock);
                            break;
                        } else if (dt > 0.1) { // audio is slower than video, skip
                            [self->aframes removeObjectAtIndex:0];
                            dispatch_semaphore_signal(self->aFramesLock);
                            continue;
                        } else {
                            self->playingAudioFrameDataPosition = 0;
                            self->playingAudioFrame = frame;
                            [self->aframes removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self->aFramesLock);
                    } else return;
                }
            }
            
            NSData *frameData = self->playingAudioFrame.data;
            NSUInteger pos = self->playingAudioFrameDataPosition;
            if (frameData == nil) {
                memset(data, 0, frames * channels * sizeof(float));
                return;
            }
            
            const void *bytes = (Byte *)frameData.bytes + pos;
            const NSUInteger remainingBytes = frameData.length - pos;
            const NSUInteger channelSize = channels * sizeof(float);
            const NSUInteger bytesToCopy = MIN(frames * channelSize, remainingBytes);
            const NSUInteger framesToCopy = bytesToCopy / channelSize;
            
            memcpy(data, bytes, bytesToCopy);
            frames -= framesToCopy;
            data += framesToCopy * channels;
            
            if (bytesToCopy < remainingBytes) {
                self->playingAudioFrameDataPosition += bytesToCopy;//移位 读剩下的数据
            } else {
                self->playingAudioFrame = nil;//数据读完， 下次循环 读下一帧
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
