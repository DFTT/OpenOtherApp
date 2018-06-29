//
//  MPB_OpenAppManager.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/11.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPB_OpenAppPlatform.h"
#import "MPB_OpenAppResp.h"
@protocol MOPOpenAppManagerDelegate;
@interface MPB_OpenAppManager : NSObject
//!@brief 初始化
+ (void)initializeConfiguration;
//!@brief 处理第三方 app 回调
+ (BOOL)handleOpenUrl:(NSURL *)url;
//!@brief 判断第三方是否安装 或者 第三方版本是否支持api 调用
+ (BOOL)isAppInstalled:(MOPOpenAppPlatformType)appname;

//!@brief 分享到...
//!@param platformType 平台
//!@param delegate 代理
//!@param shareReqModel 带分享信息的 model
+ (void)shareToPlatform:(MOPOpenAppPlatformType)platformType
         delegate:(__weak id<MOPOpenAppManagerDelegate>)delegate
               shareReq:(id)shareReqModel;

//TODO:
//!@brief 获取第三方 app 帐号信息
+ (void)getOtherAppAccountInfoPlatform:(MOPOpenAppPlatformType)platformType
                        delegate:(__weak id<MOPOpenAppManagerDelegate>)delegate;
//
@end

@protocol MOPOpenAppManagerDelegate<NSObject>
@optional;
- (void)mopOpenAppCompletionHandeler:(MPB_OpenAppResp *)resp;
@end

