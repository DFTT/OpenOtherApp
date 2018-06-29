//
//  MPB_OpenAppPlatform.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppPlatform.h"
#import "MPB_OpenAppReq.h"
#import "MPB_OpenAppPlatformQQ.h"
#import "MPB_OpenAppPlatformWechat.h"
#import "MPB_OpenAppPlatformWeibo.h"
@interface MPB_OpenAppPlatform()
@end
@implementation MPB_OpenAppPlatform

+ (Class)platformWithType:(MOPOpenAppPlatformType)type{
    switch (type) {
        case MOPOpenAppPlatformType_QQ:
        case MOPOpenAppPlatformType_Qzone:
            return MPB_OpenAppPlatformQQ.self;
            break;
        case MOPOpenAppPlatformType_WechatSession:
        case MOPOpenAppPlatformType_WechatTimeline:
            return MPB_OpenAppPlatformWechat.self;
        case MOPOpenAppPlatformType_Weibo:
            return MPB_OpenAppPlatformWeibo.self;
        case MOPOpenAppPlatformType_None:
            return nil;
    }
}
+ (void)registerApps{ }
+ (BOOL)isAppInstalled{return NO;}
+ (BOOL)handleOpenUrl:(NSURL *)url completion:(void (^)(MPB_OpenAppResp *))completion{return NO;}
+ (void)shareReq:(MPB_OpenAppReq *)req type:(MOPOpenAppPlatformType)type error:(void (^)(MPB_OpenAppResp *))error{ }
+ (void)getSocialAppUserInfoPlatform:(MOPOpenAppPlatformType)type{ }


@end
