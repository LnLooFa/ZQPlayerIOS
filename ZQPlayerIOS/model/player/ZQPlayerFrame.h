//
//  ZQPlayerFrame.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/23.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    ZQPlayerFrameTypeNone,
    ZQPlayerFrameTypeVideo,
    ZQPlayerFrameTypeAudio
} ZQPlayerFrameType;

@interface ZQPlayerFrame : NSObject
@property (nonatomic) ZQPlayerFrameType type;
@property (nonatomic) NSData *data;
@property (nonatomic) double position;
@property (nonatomic) double duration;
@end
