//
//  UtilsMacro.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/13.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

// 判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

//判断iPhoneX
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)


#define IS_IPhoneX      ((IS_IPHONE_X == YES  || IS_IPHONE_Xr == YES || IS_IPHONE_Xr == YES || IS_IPHONE_Xs_Max == YES) ? YES : NO)


/** 屏幕大小 */
#define kScreenBounds [UIScreen mainScreen].bounds
/** 全局宽度 */
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
/** 全局高度 */
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define Rect(x,y,w,h) CGRectMake(x, y, w, h)
/** 获取frame的宽度 */
#define SIZE_WIDTH(v)   v.size.width
/** 获取frame的高度 */
#define SIZE_HEIGHT(v)  v.size.height

// 适配iPhoneX系列屏幕
#define kStatusBarHeight   (IS_IPhoneX ? 44 : 20)  // 适配iPhoneX 状态栏栏高度
#define kNaviBarHeight     (IS_IPhoneX ? 88 : 64)  // 适配iPhoneX 导航栏高度
#define kNaviBarPostionY   (IS_IPhoneX ? 22 : 0)

#define kTabBarHeight      (IS_IPhoneX ? 83 : 49)  // 适配iPhoneX 底栏高度
#define kTabBarPostionY    (IS_IPhoneX ? 24 : 0)   // 适配iPhoneX 底栏


#endif /* UtilsMacro_h */
