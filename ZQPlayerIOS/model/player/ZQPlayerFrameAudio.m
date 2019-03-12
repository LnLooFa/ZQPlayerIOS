//
//  ZQPlayerFrameAudio.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/11.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ZQPlayerFrameAudio.h"

@implementation ZQPlayerFrameAudio
- (id)init {
    self = [super init];
    if (self) {
        self.type = ZQPlayerFrameTypeAudio;
    }
    return self;
}
@end
