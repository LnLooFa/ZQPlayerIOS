//
//  Decoder.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/10.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "Decoder.h"
#import <libavformat/avformat.h>
#import <libavutil/imgutils.h>
#import <libswscale/swscale.h>
#import <libavutil/eval.h>
#import <libavutil/display.h>
#import <libswresample/swresample.h>
#import "ZQPlayerFrameVideoRGB.h"
#import "ZQPlayerFrameAudio.h"
#import <Accelerate/Accelerate.h>
#define IOTimeout 30
static NSTimeInterval sIOStartTime = 0;
static int interruptCallback(void *context) {
    NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval dt = t - sIOStartTime;
    if (sIOStartTime || dt > IOTimeout) return 1;
    return 0;
}

@interface Decoder(){
    AVFormatContext *mFormatContext;
    BOOL mIsEOF;
    // Video
    int mVideoStreamIndex;
    AVFrame *mVideoFrame;
    AVFrame *mVideoSwsFrame;
    AVCodecContext *mVideoCodecContext;
    struct SwsContext *mVideoSwsContext;
    double mVideoFPS;
    double mVideoTimebase;
    double mRotation;
    double mDuration;
    BOOL mHasVideo;
    
    //Audio
    int mAudioStreamIndex;
    float mAudioSampleRate;
    UInt32 mAudioChannels;
    AVFrame *mAudioFrame;
    double mAudioTimebase;
    AVCodecContext *mAudioCodecContext;
    SwrContext *mAudioSwrContext;
    void *mAudioSwrBuffer;
    int mAudioSwrBufferSize;
    BOOL mHasAudio;
}
@end

@implementation Decoder

- (instancetype)init
{
    self = [super init];
    if (self) {
        mIsEOF = NO;
        mVideoStreamIndex = -1;
        mAudioStreamIndex = -1;
        mHasAudio = FALSE;
        mHasVideo = FALSE;
    }
    return self;
}

-(BOOL)isEndOfFile{
    return mIsEOF;
}

-(BOOL)hasVideo{
    return mHasVideo;
}

-(void)setAudioSampleRate:(double) sampleRate{
    mAudioSampleRate = sampleRate;
}

-(void)setAudioChannels:(double) channels{
    mAudioChannels = channels;
}

-(BOOL)open:(NSString*)url{
    mIsEOF = NO;
    //1、Init
    NSLog(@"1、ffmpeg init 初始化");
    avformat_network_init();
    //2、Open Input 获取输入的上下文
    NSLog(@"2、ffmpeg 获取输入的上下文");
    AVFormatContext *formatContext = NULL;
    int ret = avformat_open_input(&formatContext, [url UTF8String], NULL, NULL);
    if (ret != 0) {
        NSLog(@"2、ffmpeg 获取输入的上下文 失败");
        if (formatContext != NULL){
            avformat_free_context(formatContext);
        }
        return NO;
    }
    //打印信息
    av_dump_format(formatContext, 0, [url UTF8String], 0);
    // 3. Analyze Stream Info 流信息
    NSLog(@"3、ffmpeg 获取 流信息");
    ret = avformat_find_stream_info(formatContext, NULL);
    if (ret != 0) {
        NSLog(@"3、ffmpeg 获取 流信息 失败");
        if (formatContext != NULL){
            avformat_close_input(&formatContext);
        }
        return NO;
    }
    
    //4、遍历流信息, 初始化 video coder
    if(![self initVideoCoder:formatContext]){
        return NO;
    }
    if(![self initAudioCoder:formatContext]){
        return NO;
    }
    
    //变量赋值
    mFormatContext = formatContext;
    int64_t duration = formatContext->duration;
    mDuration = (duration == AV_NOPTS_VALUE ? -1 : ((double)duration / AV_TIME_BASE));
    //FFmpeg长时间无响应的解决方法  中断
    AVIOInterruptCB icb = {interruptCallback, NULL};
    formatContext->interrupt_callback = icb;
    
    return YES;
}

-(BOOL)initVideoCoder:(AVFormatContext *)formatContext{
    NSLog(@"4、遍历流信息");
    int ret;
    int videoStreamIndex = -1;
    AVCodecContext *videoCodeCtx = NULL;
    for (int i = 0; i < formatContext->nb_streams; ++i) {
        //视频
        if (formatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStreamIndex = i;
            videoCodeCtx = [self openCodec:formatContext stream:videoStreamIndex];
            break;
        }
    }
    
    BOOL isYUV = NO;
    AVFrame *vframe = NULL;
    AVFrame *vswsframe = NULL;
    struct SwsContext *swsctx = NULL;
    if (videoStreamIndex >= 0 && videoCodeCtx != NULL) {
        if (videoCodeCtx->pix_fmt != AV_PIX_FMT_NONE) {
            vframe = av_frame_alloc();
            isYUV = (videoCodeCtx->pix_fmt == AV_PIX_FMT_YUV420P || videoCodeCtx->pix_fmt == AV_PIX_FMT_YUVJ420P);
            //非YUV 数据要进行转换 (暂时全都转换吧)
            //            if (!isYUV) {
            NSLog(@"非YUV 数据要进行转换");
            vswsframe = av_frame_alloc();
            ret = av_image_alloc(vswsframe->data, vswsframe->linesize, videoCodeCtx->width, videoCodeCtx->height, AV_PIX_FMT_RGBA, 1);
            swsctx = sws_getContext(videoCodeCtx->width, videoCodeCtx->height, videoCodeCtx->pix_fmt,
                                    videoCodeCtx->width, videoCodeCtx->height, AV_PIX_FMT_RGBA,
                                    SWS_BILINEAR, NULL, NULL, NULL);
            //            }
            //获得fps，时间基， 用于同步
            AVStream *stream = formatContext->streams[videoStreamIndex];
            double fps = 0, timeBase = 0.04;
            if (stream->time_base.den > 0 && stream->time_base.num > 0) {
                timeBase = av_q2d(stream->time_base);
            }
            if (stream->avg_frame_rate.den > 0 && stream->avg_frame_rate.num) {
                fps = av_q2d(stream->avg_frame_rate);
            } else if (stream->r_frame_rate.den > 0 && stream->r_frame_rate.num > 0) {
                fps = av_q2d(stream->r_frame_rate);
            } else {
                fps = 1 / timeBase;
            }
            mVideoFPS = fps;
            mVideoTimebase = timeBase;
            mRotation = [self rotationFromVideoStream:stream];
        }
        
        //        BOOL swsError = isYUV ? NO : (swsctx == NULL || vswsframe == NULL);
        BOOL swsError = NO;
        //失败释放资源
        if (vframe == NULL || swsError || ret < 0) {
            NSLog(@"ffmpeg 获取编码器失败 释放资源");
            videoStreamIndex = -1;
            if (videoCodeCtx != NULL) avcodec_free_context(&videoCodeCtx);
            if (vframe != NULL) av_frame_free(&vframe);
            if (vswsframe != NULL) av_frame_free(&vswsframe);
            if (swsctx != NULL) { sws_freeContext(swsctx); swsctx = NULL; }
            return NO;
        }
    }else{
        NSLog(@"ffmpeg 获取编码器失败");
        if (formatContext != NULL){
            avformat_close_input(&formatContext);
        }
        return NO;
    }
    
    //变量赋值
    mVideoStreamIndex = videoStreamIndex;
    mVideoFrame = vframe;
    mVideoSwsFrame = vswsframe;
    mVideoCodecContext = videoCodeCtx;
    mVideoSwsContext = swsctx;
    mHasVideo = TRUE;
    return YES;
}

-(BOOL)initAudioCoder:(AVFormatContext *)formatContext{
    NSLog(@"4、遍历流信息");
    int ret;
    int audioStreamIndex = -1;
    AVCodecContext *audioCodeCtx = NULL;
    for (int i = 0; i < formatContext->nb_streams; ++i) {
        //音频
        if (formatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            audioStreamIndex = i;
            audioCodeCtx = [self openCodec:formatContext stream:audioStreamIndex];
            break;
        }
    }
    AVFrame *aframe = NULL;
    SwrContext *aswrctx = NULL;
    double timeBase = 0.025;
    if (audioStreamIndex >= 0 && audioCodeCtx != NULL) {
        aframe = av_frame_alloc();
        AVStream *stream = formatContext->streams[audioStreamIndex];
        
        if (stream->time_base.den > 0 && stream->time_base.num > 0) {
            timeBase = av_q2d(stream->time_base);
        }
        if (aframe == NULL) {
            audioStreamIndex = -1;
            if (audioCodeCtx != NULL) avcodec_free_context(&audioCodeCtx);
        }
        
        aswrctx = swr_alloc_set_opts(NULL,
                                     av_get_default_channel_layout(mAudioChannels),
                                     AV_SAMPLE_FMT_S16,
                                     mAudioSampleRate,
                                     av_get_default_channel_layout(audioCodeCtx->channels),
                                     audioCodeCtx->sample_fmt,
                                     audioCodeCtx->sample_rate,
                                     0,
                                     NULL);
        if (aswrctx == NULL) {
            audioStreamIndex = -1;
            if (audioCodeCtx != NULL) avcodec_free_context(&audioCodeCtx);
            if (aframe != NULL) av_frame_free(&aframe);
            return NO;
        }
        ret = swr_init(aswrctx);
        if (ret < 0) {
            audioStreamIndex = -1;
            if (aswrctx != NULL) swr_free(&aswrctx);
            if (audioCodeCtx != NULL) avcodec_free_context(&audioCodeCtx);
            if (aframe != NULL) av_frame_free(&aframe);
            return NO;
        }
    }else{
        NSLog(@"ffmpeg 获取编码器失败");
        if (formatContext != NULL){
            avformat_close_input(&formatContext);
        }
        return NO;
    }
    
    //变量赋值
    mAudioStreamIndex = audioStreamIndex;
    mAudioFrame = aframe;
    mAudioTimebase = timeBase;
    mAudioCodecContext = audioCodeCtx;
    mAudioSwrContext = aswrctx;
    mHasAudio = TRUE;
    return YES;
}



//初始化 编码器上下文
- (AVCodecContext *)openCodec:(AVFormatContext *)fmtctx stream:(int)stream {
    AVCodecParameters *params = fmtctx->streams[stream]->codecpar;
    AVCodec *codec = avcodec_find_decoder(params->codec_id);
    if (codec == NULL) return NULL;
    
    AVCodecContext *context = avcodec_alloc_context3(codec);
    if (context == NULL) return NULL;
    
    int ret = avcodec_parameters_to_context(context, params);
    if (ret < 0) {
        avcodec_free_context(&context);
        return NULL;
    }
    
    ret = avcodec_open2(context, codec, NULL);
    if (ret < 0) {
        avcodec_free_context(&context);
        return NULL;
    }
    
    return context;
}

//获取旋转
- (double)rotationFromVideoStream:(AVStream *)stream {
    double rotation = 0;
    AVDictionaryEntry *entry = av_dict_get(stream->metadata, "rotate", NULL, AV_DICT_MATCH_CASE);
    if (entry && entry->value) { rotation = av_strtod(entry->value, NULL); }
    //提取变换矩阵的旋转分量。
    uint8_t *display_matrix = av_stream_get_side_data(stream, AV_PKT_DATA_DISPLAYMATRIX, NULL);
    if (display_matrix) { rotation = -av_display_rotation_get((int32_t *)display_matrix); }
    return rotation;
}


- (NSArray *)readFrames {
    AVPacket packet;
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:15];
    BOOL reading = YES;
    while (reading) {
        sIOStartTime = [NSDate timeIntervalSinceReferenceDate];
        int ret = av_read_frame(self->mFormatContext, &packet);
        if (ret < 0) {
            if (ret == AVERROR_EOF) self->mIsEOF = YES;
            char *e = av_err2str(ret);
            NSLog(@"read frame error: %s", e);
            break;
        }
        
        
        NSArray<ZQPlayerFrame *> *fs = nil;
        if (packet.stream_index == self->mVideoStreamIndex) {
            fs = [self handleVideoPacket:&packet byContext:self->mVideoCodecContext andFrame:self->mVideoFrame andSwsContext:self->mVideoSwsContext andSwsFrame:self->mVideoSwsFrame];
            reading = NO;
        }else if(packet.stream_index == self->mAudioStreamIndex){
            fs = [self handleAudioPacket:&packet byContext:mAudioCodecContext andFrame:mAudioFrame andSwrContext:mAudioSwrContext andSwrBuffer:&mAudioSwrBuffer andSwrBufferSize:&mAudioSwrBufferSize];
            reading = NO;
        }
        
        if (fs != nil && fs.count > 0) [frames addObjectsFromArray:fs];
        av_packet_unref(&packet);
    }
    return frames;
}

- (NSArray<ZQPlayerFrameVideo *> *)handleVideoPacket:(AVPacket *)packet byContext:(AVCodecContext *)context andFrame:(AVFrame *)frame andSwsContext:(struct SwsContext *)swsctx andSwsFrame:(AVFrame *)swsframe {
    int ret = avcodec_send_packet(context, packet);
    if (ret != 0) { NSLog(@"avcodec_send_packet: %d", ret); return nil; }
    NSMutableArray<ZQPlayerFrameVideo *> *frames = [NSMutableArray array];
    const int width = context->width;
    const int height = context->height;
    do {
        ZQPlayerFrameVideo *f = nil;
        ret = avcodec_receive_frame(context, frame);
        if (ret == AVERROR_EOF || ret == AVERROR(EAGAIN)){
            break;
        }else if (ret < 0) {
            NSLog(@"avcodec_receive_frame: %d", ret);
            break;
        }
        sws_scale(swsctx,
                  (uint8_t const **)frame->data,
                  frame->linesize,
                  0,
                  context->height,
                  swsframe->data,
                  swsframe->linesize);
        ZQPlayerFrameVideoRGB *rgbFrame = [[ZQPlayerFrameVideoRGB alloc] init];
        rgbFrame.linesize = swsframe->linesize[0];
        rgbFrame.data = [NSData dataWithBytes:swsframe->data[0] length:rgbFrame.linesize * height];
        
        
        f = rgbFrame;
        f.width = width;
        f.height = height;
        f.position = frame->best_effort_timestamp * self->mVideoTimebase;
        double duration = frame->pkt_duration;
        if (duration > 0) {
            f.duration = duration * self->mVideoTimebase;
            f.duration += frame->repeat_pict * self->mVideoTimebase * 0.5;
        } else {
            f.duration = 1 / self->mVideoFPS;
        }
        [frames addObject:f];
    } while(ret == 0);
    return frames;
}

- (NSArray<ZQPlayerFrameAudio *> *)handleAudioPacket:(AVPacket *)packet byContext:(AVCodecContext *)context andFrame:(AVFrame *)frame andSwrContext:(SwrContext *)swrctx andSwrBuffer:(void **)swrbuf andSwrBufferSize:(int *)swrbufsize {

    int ret = avcodec_send_packet(context, packet);
    if (ret != 0) { NSLog(@"avcodec_send_packet: %d", ret); return nil; }
    
    NSMutableArray<ZQPlayerFrameAudio *> *frames = [NSMutableArray array];
    do {
        ret = avcodec_receive_frame(context, frame);
        if (ret == AVERROR_EOF || ret == AVERROR(EAGAIN)) { break; }
        else if (ret < 0) { NSLog(@"avcodec_receive_frame: %d", ret); break; }
        if (frame->data[0] == NULL) continue;
        
        const float sampleRate = mAudioSampleRate;
        const UInt32 channels = mAudioChannels;
        
        void *data = NULL;
        NSInteger samplesPerChannel = 0;
        if (swrctx != NULL && swrbuf != NULL) {
            float sampleRatio = sampleRate / context->sample_rate;
            float channelRatio = channels / context->channels;
            float ratio = MAX(1, sampleRatio) * MAX(1, channelRatio) * 2;
            int samples = frame->nb_samples * ratio;
            int bufsize = av_samples_get_buffer_size(NULL,
                                                     channels,
                                                     samples,
                                                     AV_SAMPLE_FMT_S16,
                                                     1);
            if (*swrbuf == NULL || *swrbufsize < bufsize) {
                *swrbufsize = bufsize;
                *swrbuf = realloc(*swrbuf, bufsize);
            }
            
            Byte *o[2] = { *swrbuf, 0 };
            samplesPerChannel = swr_convert(swrctx, o, samples, (const uint8_t **)frame->data, frame->nb_samples);
            if (samplesPerChannel < 0) {
                NSLog(@"failed to resample audio");
                return nil;
            }
            
            data = *swrbuf;
        } else {
            if (context->sample_fmt != AV_SAMPLE_FMT_S16) {
                NSLog(@"invalid audio format");
                return nil;
            }
            
            data = frame->data[0];
            samplesPerChannel = frame->nb_samples;
        }
        
        NSUInteger elements = samplesPerChannel * channels;
        NSUInteger dataLength = elements * sizeof(float);
        NSMutableData *mdata = [NSMutableData dataWithLength:dataLength];
        
        float scalar = 1.0f / INT16_MAX;
        vDSP_vflt16(data, 1, mdata.mutableBytes, 1, elements);
        vDSP_vsmul(mdata.mutableBytes, 1, &scalar, mdata.mutableBytes, 1, elements);
        
        ZQPlayerFrameAudio *f = [[ZQPlayerFrameAudio alloc] init];
        f.data = mdata;
        f.position = frame->best_effort_timestamp * mAudioTimebase;
        f.duration = frame->pkt_duration * mAudioTimebase;
        
        if (f.duration == 0)
            f.duration = f.data.length / (sizeof(float) * channels * sampleRate);
        
        [frames addObject:f];
    } while(ret == 0);
    
    return frames;
}

@end
