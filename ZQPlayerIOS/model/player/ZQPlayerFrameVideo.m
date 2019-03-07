//
//  ZQPlayerFrameVideo.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/23.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ZQPlayerFrameVideo.h"

@implementation ZQPlayerFrameVideo
- (id)init {
    self = [super init];
    if (self) {
        self.type = ZQPlayerFrameTypeVideo;
    }
    return self;
}
@end
