//
//  VideoListItemModel.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/24.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoListItemModel : NSObject
{
    NSString* vid;
}
@property (nonatomic, copy) NSString* id;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *name;
@end
