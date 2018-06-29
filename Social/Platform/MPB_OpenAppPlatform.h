//
//  MPB_OpenAppPlatform.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPB_OpenAppResp.h"
#import "MPB_Config.h"
#import "MPB_OpenAppConst.h"
@class MPB_OpenAppReq;
@interface MPB_OpenAppPlatform : NSObject
+ (Class)platformWithType:(MOPOpenAppPlatformType)type;

//MARK: rewrite
+ (void)registerApps;
+ (BOOL)isAppInstalled;
+ (BOOL)handleOpenUrl:(NSURL *)url completion:(void(^)(MPB_OpenAppResp *))completion;
@property (nonatomic, copy) void(^handelResp)(MPB_OpenAppResp *);
//!@brief 分享
//!@param req - 含分享信息的对象
+ (void)shareReq:(MPB_OpenAppReq *)req type:(MOPOpenAppPlatformType)type error:(void(^)(MPB_OpenAppResp *))error;
//!@brief 获取第三方账户用户信息
+ (void)getSocialAppUserInfoPlatform:(MOPOpenAppPlatformType)type;
@end

