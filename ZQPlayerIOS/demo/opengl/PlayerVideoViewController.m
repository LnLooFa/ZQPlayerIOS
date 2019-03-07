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

static BOOL S_IS_PlAYING;
@interface PlayerVideoViewController (){
    
    AVFormatContext *mFormatContext;
    
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
    
    BOOL mIsPlaying;
    NSThread *mFrameReaderThread;
    dispatch_block_t renderFrameBlock;
    BOOL mIsEOF;
    
    //缓存判断
    double mMinBufferDuration;
    double mMaxBufferDuration;
    double mBufferedDuration;//当前缓存
    
    NSMutableArray *vframes;
}

@end

@implementation PlayerVideoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        S_IS_PlAYING = NO;
        mIsPlaying = NO;
        mIsEOF = NO;
        mMinBufferDuration = 2;
        mMaxBufferDuration = 5;
        mBufferedDuration = 0;
        vframes = [NSMutableArray arrayWithCapacity:128];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPlayer];
}

- (void)viewWillDisappear:(BOOL)animated{
    S_IS_PlAYING = FALSE;//用静态变量 ，不然为了解除强引用，viewWillDisappear时候解除
    mIsPlaying = FALSE;
    if(mFrameReaderThread != nil){
        mFrameReaderThread = nil;
    }
    if(renderFrameBlock != nil){
        renderFrameBlock = nil;
    }
}

- (void)dealloc
{
    NSLog(@"ziq player dealloc");
}




-(void)initPlayer{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        //初始化
        NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"gao_bai_qi_qiu.mp4" ofType:nil];
        if(![strongSelf open:urlStr]){
            return;
        }
        
        S_IS_PlAYING = TRUE;
        strongSelf->mIsPlaying = TRUE;
        //解码线程
        NSLog(@"readFrameRunnable %@", S_IS_PlAYING?@"YES":@"NO");
        [strongSelf startFrameReaderThread];
        //渲染线程
        strongSelf->renderFrameBlock = dispatch_block_create(0, ^{
            while (strongSelf->mIsPlaying) {
                if(self->vframes.count > 0 && !self->mIsEOF){
                    
                }else{
                    NSLog(@"render sleep");
                    [NSThread sleepForTimeInterval:1];
                }
            }
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), strongSelf->renderFrameBlock);
        
        
    });
}

-(BOOL)open:(NSString*)url{
    //1、Init
    NSLog(@"1、ffmpeg init 初始化");
    avformat_network_init();
    //2、Open Input 获取输入的上下文
    NSLog(@"2、ffmpeg 获取输入的上下文");
    AVFormatContext * formatContext = NULL;
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
    
    //4、遍历流信息
    NSLog(@"4、遍历流信息");
    int videoStreamIndex = -1;
    AVCodecContext *videoCodeCtx = NULL;
    for (int i = 0; i < formatContext->nb_streams; ++i) {
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
                ret = av_image_alloc(vswsframe->data, vswsframe->linesize, videoCodeCtx->width, videoCodeCtx->height, AV_PIX_FMT_RGB24, 1);
                swsctx = sws_getContext(videoCodeCtx->width, videoCodeCtx->height, videoCodeCtx->pix_fmt,
                                        videoCodeCtx->width, videoCodeCtx->height, AV_PIX_FMT_RGB24,
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
        }
    }else{
        NSLog(@"ffmpeg 获取编码器失败");
        if (formatContext != NULL){
            avformat_close_input(&formatContext);
        }
        return NO;
    }
    
    //变量赋值
    mFormatContext = formatContext;
    mVideoStreamIndex = videoStreamIndex;
    mVideoFrame = vframe;
    mVideoSwsFrame = vswsframe;
    mVideoCodecContext = videoCodeCtx;
    mVideoSwsContext = swsctx;
    int64_t duration = formatContext->duration;
    mDuration = (duration == AV_NOPTS_VALUE ? -1 : ((double)duration / AV_TIME_BASE));
    return YES;
}

- (void)startFrameReaderThread {
    
    if (mFrameReaderThread == nil) {
        mFrameReaderThread = [[NSThread alloc] initWithTarget:self selector:@selector(readFrameRunnable) object:nil];
        [mFrameReaderThread start];
    }
}

-(void)readFrameRunnable{
    @autoreleasepool {
        dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC);
        NSDate *datenow;
        while (self->mIsPlaying && !self->mIsEOF) {
            datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
            NSLog(@"readFrameRunnable %ld %f %llu", (long)[datenow timeIntervalSince1970] , 0.02 * NSEC_PER_SEC, t);
            //读取音视频帧
            NSArray *fs = [self readFrames];
            if (fs == nil) { break; }
            if (fs.count == 0) { continue; }
            NSLog(@"ziq readFrames size = %lu", (unsigned long)fs.count);
            
            for (ZQPlayerFrame *f in fs) {
                if (f.type == ZQPlayerFrameTypeVideo) {
                    [self->vframes addObject:f];
                }
            }
            [NSThread sleepForTimeInterval:1];
        }
        mFrameReaderThread = nil;
    }
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
        int ret = av_read_frame(self->mFormatContext, &packet);
        if (ret < 0) {
            if (ret == AVERROR_EOF) self->mIsEOF = YES;
            char *e = av_err2str(ret);
            NSLog(@"read frame error: %s", e);
            break;
        }
        
        
        NSArray<ZQPlayerFrame *> *fs = nil;
        if (packet.stream_index == self->mVideoStreamIndex) {
            NSLog(@"ziq handleVideoPacket----------");
            fs = [self handleVideoPacket:&packet byContext:self->mVideoCodecContext andFrame:self->mVideoFrame andSwsContext:self->mVideoSwsContext andSwsFrame:self->mVideoSwsFrame];
            NSLog(@"ziq video frame size = %lu", (unsigned long)fs.count);
            reading = NO;
        }
        
        if (fs != nil && fs.count > 0) [frames addObjectsFromArray:fs];
        av_packet_unref(&packet);
    }
    return frames;
}


- (NSArray<ZQPlayerFrameVideo *> *)handleVideoPacket:(AVPacket *)packet byContext:(AVCodecContext *)context andFrame:(AVFrame *)frame andSwsContext:(struct SwsContext *)swsctx andSwsFrame:(AVFrame *)swsframe {
    
    NSLog(@"ziq handleVideoPacket avcodec_send_packet");
    int ret = avcodec_send_packet(context, packet);
    if (ret != 0) { NSLog(@"avcodec_send_packet: %d", ret); return nil; }
    NSMutableArray<ZQPlayerFrameVideo *> *frames = [NSMutableArray array];
    const int width = context->width;
    const int height = context->height;
    do {
        ZQPlayerFrameVideo *f = nil;
        NSLog(@"ziq handleVideoPacket avcodec_receive_frame do ");
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
        NSLog(@"video frame: %@", f);
        [frames addObject:f];
    } while(ret == 0);
    return frames;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
