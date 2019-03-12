//
//  AudioUnitManager.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/9.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AudioManagerFrameReaderBlock)(float *data, UInt32 num, UInt32 channels);

@interface AudioUnitManager : NSObject
@property (nonatomic, copy) AudioManagerFrameReaderBlock frameReaderBlock;
- (double)sampleRate;
- (UInt32)channels;
- (BOOL)open;
- (BOOL)play;
- (BOOL)pause;
@end
