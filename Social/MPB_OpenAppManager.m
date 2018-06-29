//
//  MPB_OpenAppManager.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/11.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppManager.h"
#import "MPB_SocialShareSheet.h"
#import "MPB_OpenAppReq.h"
#import "MPB_CommonHeader.h"
#import "MPB_OpenAppPlatformQQ.h"
#import "MPB_OpenAppPlatformWechat.h"
#import "MPB_OpenAppPlatformWeibo.h"
@interface MPB_OpenAppManager()
@property (nonatomic,weak) id<MOPOpenAppManagerDelegate>delegate;
@property (nonatomic) MPB_OpenAppPlatform *platform;
@property (nonatomic,assign) MOPOpenAppPlatformType platformType;
@end
@implementation MPB_OpenAppManager

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static MPB_OpenAppManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MPB_OpenAppManager alloc] init];
    });
    return manager;
}

+ (void)initializeConfiguration{
    [MPB_OpenAppPlatformQQ registerApps];
    [MPB_OpenAppPlatformWechat registerApps];
    [MPB_OpenAppPlatformWeibo registerApps];
}

+ (BOOL)isAppInstalled:(MOPOpenAppPlatformType)appname{
    switch (appname) {
        case MOPOpenAppPlatformType_QQ:
        case MOPOpenAppPlatformType_Qzone:
          return [MPB_OpenAppPlatformQQ isAppInstalled];
        case MOPOpenAppPlatformType_WechatSession:
        case MOPOpenAppPlatformType_WechatTimeline:
            return [MPB_OpenAppPlatformWechat isAppInstalled];
        case MOPOpenAppPlatformType_Weibo:
            return [MPB_OpenAppPlatformWeibo isAppInstalled];
        default:
            return NO;
    }
}

+ (BOOL)handleOpenUrl:(NSURL *)url{
    return [[self platformWithUrl:url] handleOpenUrl:url
                                          completion:^(MPB_OpenAppResp *resp) {
        if ([[MPB_OpenAppManager shareInstance].delegate respondsToSelector:@selector(mopOpenAppCompletionHandeler:)]) {
            resp.platform = [MPB_OpenAppManager shareInstance].platformType;
            [[MPB_OpenAppManager shareInstance].delegate mopOpenAppCompletionHandeler:resp];
            [MPB_OpenAppManager shareInstance].platformType = MOPOpenAppPlatformType_None;
        }
    }];
}

+ (Class)platformWithUrl:(NSURL *)url{
    if ([url.absoluteString rangeOfString:MPB_Config.wechatAppid].location != NSNotFound) {
        return MPB_OpenAppPlatformWechat.self;
    }else if ([url.absoluteString rangeOfString:[@"tencent" stringByAppendingString:MPB_Config.qqAppid]].location != NSNotFound){
        return MPB_OpenAppPlatformQQ.self;
    }else if ([url.absoluteString rangeOfString:[@"wb" stringByAppendingString:MPB_Config.weiboAppkey]].location != NSNotFound){
        return MPB_OpenAppPlatformWeibo.self;
    }
    return MPB_OpenAppPlatform.self;
}



// share
+ (void)shareToPlatform:(MOPOpenAppPlatformType)platformType delegate:(__weak id<MOPOpenAppManagerDelegate>)delegate shareReq:(id)shareReqModel{
    MPB_OpenAppManager *manager = [MPB_OpenAppManager shareInstance];
    manager.delegate = delegate;
    manager.platformType = platformType;
    
    if (![self isAppInstalled:platformType]) {
        MPB_OpenAppResp *resp = [[MPB_OpenAppResp alloc] init];
        resp.code = MOPOpenAppResponseStatusCodeAppUninstall ;
        resp.platform = platformType;
        [manager.delegate mopOpenAppCompletionHandeler:resp];
        return;
    }
    
    [[MPB_OpenAppPlatform platformWithType:platformType] shareReq:shareReqModel type:platformType error:^(MPB_OpenAppResp *resp){
        if ([manager.delegate respondsToSelector:@selector(mopOpenAppCompletionHandeler:)]) {
            resp.platform = manager.platformType;
            [manager.delegate mopOpenAppCompletionHandeler:resp];
        }
    }];
}

+ (void)getOtherAppAccountInfoPlatform:(MOPOpenAppPlatformType)platformType delegate:(__weak id<MOPOpenAppManagerDelegate>)delegate{
    MPB_OpenAppManager *manager = [MPB_OpenAppManager shareInstance];
    manager.delegate = delegate;
    manager.platformType = platformType;
    
    if (platformType == MOPOpenAppPlatformType_QQ || platformType == MOPOpenAppPlatformType_WechatSession) {
        if (![self isAppInstalled:platformType]) {
            MPB_OpenAppResp *resp = [[MPB_OpenAppResp alloc] init];
            resp.code = MOPOpenAppResponseStatusCodeAppUninstall ;
            resp.platform = platformType;
            [manager.delegate mopOpenAppCompletionHandeler:resp];
            return;
        }
    }

    [[MPB_OpenAppPlatform platformWithType:platformType] getSocialAppUserInfoPlatform:platformType];
}

@end
