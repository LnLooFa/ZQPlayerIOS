//
//  MediaPlayer.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/13.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "MediaPlayer.h"
#import "Decoder.h"
#import "AudioUnitManager.h"
#import "ZQPlayerFrameAudio.h"
#import "ZQPlayerFrameVideoRGB.h"
@interface MediaPlayer()
@property (nonatomic, strong) Decoder *decoder;
@property (nonatomic, strong) AudioUnitManager *audioUnitManager;
@property (nonatomic) BOOL mIsPlaying;
@property (nonatomic, strong) NSThread *mFrameReaderThread;

//缓存判断
@property (nonatomic) double mMinBufferDuration;
@property (nonatomic) double mMaxBufferDuration;
@property (nonatomic) double mBufferedDuration;//当前缓存
//video
@property (nonatomic, strong) NSMutableArray *vframes;
@property (nonatomic, strong) dispatch_semaphore_t vFramesLock;
//audio
@property (nonatomic, strong) NSMutableArray *aframes;
@property (nonatomic, strong) dispatch_semaphore_t aFramesLock;
@property (nonatomic, strong) ZQPlayerFrameAudio *playingAudioFrame;
@property (nonatomic) NSUInteger playingAudioFrameDataPosition;

@property (nonatomic) double mediaPosition;
@property (nonatomic) double mediaSyncTime;
@property (nonatomic) double mediaSyncPosition;
@end
@implementation MediaPlayer


- (id)init {
    self = [super init];
    if (self) {
        [self initAll];
    }
    return self;
}

- (void)initAll {
    [self initVars];
    [self initAudio];
    [self initDecoder];
    [self initView];
}

- (void)initVars {
    self.mIsPlaying = FALSE;
    self.mMinBufferDuration = 2;
    self.mMaxBufferDuration = 5;
    self.mBufferedDuration = 0;
    
    self.vframes = [NSMutableArray arrayWithCapacity:128];
    self.vFramesLock = dispatch_semaphore_create(1);
    self.aframes = [NSMutableArray arrayWithCapacity:128];
    self.aFramesLock = dispatch_semaphore_create(1);
    self.playingAudioFrame = nil;
    self.playingAudioFrameDataPosition = 0;
    self.mediaPosition = 0;
}

- (void)initDecoder {
    self.decoder = [[Decoder alloc] init];
}

- (void)initAudio {
    self.audioUnitManager = [[AudioUnitManager alloc] init];
}

- (void)initView {
    self.openGlView = [[OpenGlView alloc] initWithFrame:CGRectMake(100,100,200,200)];
}

- (void)pause {
    self.mIsPlaying = FALSE;
}

- (void)open:(NSString *)url {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if ([strongSelf.audioUnitManager open]) {
            NSLog(@"audioUnitManager open 成功");
            [strongSelf.decoder setAudioChannels:[strongSelf.audioUnitManager channels]];
            [strongSelf.decoder setAudioSampleRate:[strongSelf.audioUnitManager sampleRate]];
        } else {
            NSLog(@"audioUnitManager open 失败");
        }
        
        if(![strongSelf.decoder open:url]){
            return;
        }
        
        strongSelf.mIsPlaying = TRUE;
        //解码线程
        [strongSelf startFrameReaderThread];
        //渲染声音
        __weak typeof(strongSelf)ws = strongSelf;
        strongSelf.audioUnitManager.frameReaderBlock = ^(float *data, UInt32 frames, UInt32 channels){
            [ws readAudioFrame:data frames:frames channels:channels];
        };
        [strongSelf.audioUnitManager play];
        //渲染视频
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf render];
        });
        
    });
}

- (void)startFrameReaderThread {
    if (self.mFrameReaderThread == nil) {
        self.mFrameReaderThread = [[NSThread alloc] initWithTarget:self selector:@selector(readFrameRunnable) object:nil];
        [self.mFrameReaderThread start];
    }
}

-(void)readFrameRunnable{
    @autoreleasepool {
        while (self.mIsPlaying && ![self.decoder isEndOfFile]) {
            if(self.mBufferedDuration < self.mMaxBufferDuration){
                //读取音视频帧
                NSArray *fs = [self.decoder readFrames];
                if (fs == nil) { break; }
                if (fs.count == 0) { continue; }
                for (ZQPlayerFrame *f in fs) {
                    if (f.type == ZQPlayerFrameTypeVideo) {
                        [self.vframes addObject:f];
                        self.mBufferedDuration += f.duration;//音频 同步
                    }else if (f.type == ZQPlayerFrameTypeAudio) {
                        [self.aframes addObject:f];
                    }
                }
                NSLog(@"ziq 读取 frame = %lu, aframes = %lu", (unsigned long)fs.count, self.aframes.count);
            }else{
                //空运转会耗费cpu
                [NSThread sleepForTimeInterval:1.5];
            }
        }
        self.mFrameReaderThread = nil;
    }
}

- (void)readAudioFrame:(float *)data frames:(UInt32)frames channels:(UInt32)channels {
    NSLog(@"ziq 渲染音频 aframe size = %lu", (unsigned long)self.aframes.count);
    if (!self.mIsPlaying) return;
    while(frames > 0) {
        @autoreleasepool {
            if (self.playingAudioFrame == nil) {
                {
                    if (self.aframes.count <= 0) {
                        memset(data, 0, frames * channels * sizeof(float));
                        return;
                    }
                    
                    long timeout = dispatch_semaphore_wait(self.aFramesLock, DISPATCH_TIME_NOW);
                    if (timeout == 0) {
                        ZQPlayerFrameAudio *frame = self.aframes[0];
                        const double dt = self.mediaPosition - frame.position;
                        if (dt < -0.1) { // audio is faster than video, silence
                            memset(data, 0, frames * channels * sizeof(float));
                            dispatch_semaphore_signal(self.aFramesLock);
                            break;
                        } else if (dt > 0.1) { // audio is slower than video, skip
                            [self.aframes removeObjectAtIndex:0];
                            dispatch_semaphore_signal(self.aFramesLock);
                            continue;
                        } else {
                            self.playingAudioFrameDataPosition = 0;
                            self.playingAudioFrame = frame;
                            [self.aframes removeObjectAtIndex:0];
                        }
                        dispatch_semaphore_signal(self.aFramesLock);
                    } else return;
                }
            }
            
            NSData *frameData = self.playingAudioFrame.data;
            NSUInteger pos = self.playingAudioFrameDataPosition;
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
                self.playingAudioFrameDataPosition += bytesToCopy;//移位 读剩下的数据
            } else {
                self.playingAudioFrame = nil;//数据读完， 下次循环 读下一帧
            }
        }
    }
}

- (void)render {
    if (!self.mIsPlaying) return;
    
    if (self.vframes.count <= 0) {
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf render];
        });
        return;
    }
    
    NSLog(@"ziq 渲染视频 vframe size = %lu", (unsigned long)self.vframes.count);
    ZQPlayerFrameVideoRGB *frame = self.vframes[0];
    [self.vframes removeObjectAtIndex:0];
    self.mediaPosition = frame.position;
    self.mBufferedDuration -= frame.duration;
    
    NSLog(@"ziq1 渲染视频---- ");
    [self.openGlView render:frame];
    
    double syncTime = [self syncTime];
    NSTimeInterval t = MAX(frame.duration + syncTime, 0.01);
    NSLog(@"ziq1 渲染视频mediaPosition=%f, t=%f", self.mediaPosition, t);
    
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf render];
    });
}

- (double)syncTime {
    const double now = [NSDate timeIntervalSinceReferenceDate];
    
    if (self.mediaSyncTime == 0) {
        self.mediaSyncTime = now;
        self.mediaSyncPosition = self.mediaPosition;
        return 0;
    }
    
    double dp = self.mediaPosition - self.mediaSyncPosition;
    double dt = now - self.mediaSyncTime;
    double sync = dp - dt;
    NSLog(@"ziq1 %f = %f - %f, %f = %f - %f, %f", dp,self.mediaPosition,self.mediaSyncPosition,dt,now,self.mediaSyncTime, sync);
    if (sync > 1 || sync < -1) {
        sync = 0;
        self.mediaSyncTime = 0;
    }
    
    return sync;
}


@end
