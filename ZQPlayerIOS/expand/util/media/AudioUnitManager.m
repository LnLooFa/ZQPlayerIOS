//
//  AudioUnitManager.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/9.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "AudioUnitManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioUnitProperties.h>
#import <Accelerate/Accelerate.h>

#define MAX_FRAME_SIZE  4096
#define MAX_CHANNEL     2
#define PREFERRED_SAMPLE_RATE   44100
#define PREFERRED_BUFFER_DURATION 0.023
#define kOutputBus 0
#define kInputBus 1


@interface AudioUnitManager(){
    AudioUnit _audioUnit;
    BOOL _opened;
    BOOL _playing;
    BOOL _closing;
    double _sampleRate;//采样率
    UInt32 _bitsPerChannel;//每个采样，位数32 16 精度
    UInt32 _channelsPerFrame;// 通道数
    float *_audioData;
}
@end

@implementation AudioUnitManager

-(instancetype)init{
    self = [super init];
    if(self){
        [self initVars];
    }
    return self;
}

-(void)initVars{
    _opened = NO;
    _playing = NO;
    _closing = NO;
    _sampleRate = 44100; //采样率
    _bitsPerChannel = 32;//每个采样，位数32 16 精度
    _channelsPerFrame = 16;// 通道数
    _audioData = (float *)calloc(MAX_FRAME_SIZE * MAX_CHANNEL, sizeof(float));
    _frameReaderBlock = nil;
}

- (void)dealloc {
    NSLog(@"AudioUnitManager dealloc");
    [self close];
    if (_audioData != NULL) {
        free(_audioData);
        _audioData = NULL;
    }
}

- (BOOL)open{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *rawError = nil;
    //音频的场景
    if (![session setCategory:AVAudioSessionCategoryPlayback error:&rawError]) {
        NSLog(@"AVAudioSession 错误 %@", rawError);
        return NO;
    }
    //设置首选I/O缓冲时间
    NSTimeInterval prefferedIOBufferDuration = PREFERRED_BUFFER_DURATION;
    if (![session setPreferredIOBufferDuration:prefferedIOBufferDuration error:&rawError]) {
        NSLog(@"AVAudioSession 错误 setPreferredIOBufferDuration: %.4f, error: %@", prefferedIOBufferDuration, rawError);
    }
    //采样率
    double prefferedSampleRate = PREFERRED_SAMPLE_RATE;
    if (![session setPreferredSampleRate:prefferedSampleRate error:&rawError]) {
        NSLog(@"AVAudioSession 错误 setPreferredSampleRate: %.4f, error: %@", prefferedSampleRate, rawError);
    }
    //激活Session
    if (![session setActive:YES error:&rawError]) {
        NSLog(@"AVAudioSession 错误 setActive: error: %@", rawError);
        return NO;
    }
    
    AVAudioSessionRouteDescription *route = session.currentRoute;
    if (route.outputs.count == 0) {
        NSLog(@"AVAudioSession 错误 currentRoute: %@", route);
        return NO;
    }
    
    NSInteger channels = session.outputNumberOfChannels;
    if (channels <= 0) {
        NSLog(@"AVAudioSession 错误 outputNumberOfChannels: %ld", (long)channels);
        return NO;
    }
    
    double sampleRate = session.sampleRate;
    if (sampleRate <= 0) {
        NSLog(@"AVAudioSession 错误 sampleRate: %f", sampleRate);
        return NO;
    }
    
    float volume = session.outputVolume;
    if (volume < 0) {
        NSLog(@"AVAudioSession 错误 outputVolume: %f", sampleRate);
        return NO;
    }
    
    if (![self initAudioUnitWithSampleRate:sampleRate andRenderCallback:audioUnitRenderCallback]) {
        NSLog(@"AVAudioSession 错误 初始化 audio unit");
        return NO;
    }
    _opened = YES;
    return YES;
}

- (BOOL)initAudioUnitWithSampleRate:(double)sampleRate andRenderCallback:(AURenderCallback)renderCallback{
    OSStatus status;
    // 1、描述音频元件
    AudioComponentDescription descr;
    descr.componentType = kAudioUnitType_Output;
    descr.componentSubType = kAudioUnitSubType_RemoteIO;
    descr.componentManufacturer = kAudioUnitManufacturer_Apple;
    descr.componentFlags = 0;
    descr.componentFlagsMask = 0;
    
    //2、获得一个元件
    AudioUnit audioUnit = NULL;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &descr);
    // 3、获得 Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    if (status != noErr) {
        NSLog(@"AudioUnit 错误 AudioComponentInstanceNew");
        return NO;
    }
    
    //4、设置格式
    AudioStreamBasicDescription streamDescr;
    UInt32 size = sizeof(AudioStreamBasicDescription);
    status = AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
                                  0, &streamDescr, &size);
    if (status != noErr) {
        NSLog(@"AudioUnit 错误 获取AudioStreamBasicDescription");
        return NO;
    }
    streamDescr.mSampleRate = sampleRate;
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
                                  0, &streamDescr, size);
    if (status != noErr) {
        NSLog(@"AudioUnit 错误 设置AudioStreamBasicDescription");
    }
    _sampleRate = sampleRate;
    _bitsPerChannel = streamDescr.mBitsPerChannel;
    _channelsPerFrame = streamDescr.mChannelsPerFrame;
    
    // 5、设置声音输入回调函数。
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = renderCallback;
    renderCallbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallbackStruct, sizeof(AURenderCallbackStruct));
    if (status != noErr) {
        NSLog(@"AudioUnit 错误 设置AURenderCallbackStruct");
        return NO;
    }
    // 初始化
    status = AudioUnitInitialize(audioUnit);
    if (status != noErr) {
        NSLog(@"AudioUnit 错误 Initialize");
        return NO;
    }
    _audioUnit = audioUnit;
    return YES;
}

- (double)sampleRate {
    return _sampleRate;
}

- (UInt32)channels {
    return _channelsPerFrame;
}

static OSStatus audioUnitRenderCallback(void *inRefCon,
                                        AudioUnitRenderActionFlags *ioActionFlags,
                                        const AudioTimeStamp *inTimeStamp,
                                        UInt32 inBusNumber,
                                        UInt32 inNumberFrames,
                                        AudioBufferList *ioData) {
    AudioUnitManager *manager = (__bridge AudioUnitManager *)(inRefCon);
    return [manager render:ioData count:inNumberFrames];
}

//音频输入回调，填充数据
- (OSStatus)render:(AudioBufferList *)ioData count:(UInt32)inNumberFrames{
    UInt32 num = ioData->mNumberBuffers;
    for (UInt32 i = 0; i < num; ++i) {
        AudioBuffer buf = ioData->mBuffers[i];
        memset(buf.mData, 0, buf.mDataByteSize);//设置数据0，清数据
    }
    
    if (!_playing || _frameReaderBlock == nil) return noErr;
    _frameReaderBlock(_audioData, inNumberFrames, _channelsPerFrame);
    
    if (_bitsPerChannel == 32) {
        float scalar = 0;
        for (UInt32 i = 0; i < num; ++i) {
            AudioBuffer buf = ioData->mBuffers[i];
            UInt32 channels = buf.mNumberChannels;
            for (UInt32 j = 0; j < channels; ++j) {
                vDSP_vsadd(_audioData + i + j, _channelsPerFrame, &scalar, (float *)buf.mData + j, channels, inNumberFrames);
            }
        }
    } else if (_bitsPerChannel == 16) {
        float scalar = INT16_MAX;
        vDSP_vsmul(_audioData, 1, &scalar, _audioData, 1, inNumberFrames * _channelsPerFrame);
        for (UInt32 i = 0; i < num; ++i) {
            AudioBuffer buf = ioData->mBuffers[i];
            UInt32 channels = buf.mNumberChannels;
            for (UInt32 j = 0; j < channels; ++j) {
                vDSP_vfix16(_audioData + i + j, _channelsPerFrame, (short *)buf.mData + j, channels, inNumberFrames);
            }
        }
    }
    
    
    
    return noErr;
}

- (BOOL)play {
    if (_opened) {
        OSStatus status = AudioOutputUnitStart(_audioUnit);
        _playing = (status == noErr);
        if (!_playing) {
            NSLog(@"AudioUnitManager play失败");
        }
    }
    return _playing;
}

- (BOOL)pause{
    if (_playing) {
        OSStatus status = AudioOutputUnitStop(_audioUnit);
        _playing = !(status == noErr);
        if (_playing) {
            NSLog(@"AudioUnitManager pause失败");
        }
    }
    return !_playing;
}

- (BOOL)close{
    if (_closing) return NO;
    _closing = YES;
    BOOL closed = YES;
    if (_opened) {
        [self pause];
        OSStatus status = AudioUnitUninitialize(_audioUnit);
        if (status != noErr) {
            closed = NO;
            NSLog(@"AudioUnitUninitialize失败");
        }
        status = AudioComponentInstanceDispose(_audioUnit);
        if (status != noErr) {
            closed = NO;
            NSLog(@"AudioComponentInstanceDispose失败");
        }
        AVAudioSession *session = [AVAudioSession sharedInstance];
        if (![session setActive:NO error:nil]) {
            closed = NO;
            NSLog(@"session setActive失败");
        }
        if (closed) _opened = NO;
    }
    _closing = NO;
    return closed;
}

@end
