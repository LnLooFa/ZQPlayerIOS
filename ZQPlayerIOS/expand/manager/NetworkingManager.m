//
//  NetworkingManager.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/24.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "NetworkingManager.h"



@implementation NetworkingManager

static NetworkingManager * manager = nil;

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetworkingManager alloc] initWithBaseURL:nil sessionConfiguration:nil];
    });
    return manager;
}

- (instancetype)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration{
    if (self = [super initWithBaseURL:url sessionConfiguration:configuration]) {
        /**设置请求超时时间*/
        self.requestSerializer.timeoutInterval = 30.0f;
        /**设置相应的缓存策略*/
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        /**分别设置请求以及相应的序列化器*/
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        /**分别设置返回以及相应的反序列化器*/
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        self.responseSerializer = response;
        
        /**复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        [self.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        /**设置接受的类型*/
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil]];
    }
    return self;
}



@end
