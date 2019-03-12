//
//  Decoder.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/10.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Decoder : NSObject
-(BOOL)isEndOfFile;
-(BOOL)hasVideo;
-(void)setAudioSampleRate:(double) sampleRate;
-(void)setAudioChannels:(double) channels;
-(BOOL)open:(NSString*)url;
- (NSArray *)readFrames;
@end
