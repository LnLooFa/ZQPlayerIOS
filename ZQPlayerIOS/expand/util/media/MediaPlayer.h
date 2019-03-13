//
//  MediaPlayer.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/13.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGlView.h"
@interface MediaPlayer : NSObject
@property (nonatomic, strong) OpenGlView *openGlView;
- (void)open:(NSString *)url;
- (void)pause;
@end
