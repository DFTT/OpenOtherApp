//
//  MPB_OpenAppPlatformWechat.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppPlatformWechat.h"
#import <WXApi.h>
#import "MPB_OpenAppReq.h"
#import "MPB_NetWorkManager.h"
#import "MPB_Helper.h"
@interface MPB_OpenAppPlatformWechat()<WXApiDelegate>
@end
@implementation MPB_OpenAppPlatformWechat

+ (void)registerApps{
    [WXApi registerApp:MPB_Config.wechatAppid];
}

+ (BOOL)isAppInstalled{
    return ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]);
}

+ (BOOL)handleOpenUrl:(NSURL *)url completion:(void (^)(MPB_OpenAppResp *))completion{
    MPB_OpenAppPlatformWechat *wechat = [[MPB_OpenAppPlatformWechat alloc] init];
    wechat.handelResp = completion;
    return [WXApi handleOpenURL:url delegate:wechat];
}

+ (void)shareReq:(MPB_OpenAppReq *)req type:(MOPOpenAppPlatformType)type error:(void (^)(MPB_OpenAppResp *))error{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = req.title;
    message.description = req.des;
    // 图片需要压缩到32k 以内
    [MPB_HUD mopLoadingShowOnView:nil model:MPBLoadingModelActivityIndicator].bezelView.color = [UIColor clearColor];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!req.image) {
            if (req.imageUrl) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:req.imageUrl]];
                UIImage *image = [UIImage imageWithData:imageData];
                req.image = image?:[UIImage imageNamed:MOPDefaultShareAppIcon];
            }else{
                req.image = [UIImage imageNamed:MOPDefaultShareAppIcon];
            }
        }
        [message setThumbImage:[MPB_Helper compressImage:req.image toByte:32 * 1024]];
        dispatch_async(dispatch_get_main_queue(), ^{
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = req.wx;
            message.mediaObject = ext;
            SendMessageToWXReq* wxReq = [[SendMessageToWXReq alloc] init];
            wxReq.bText = NO;
            wxReq.message = message;
            wxReq.scene =  type == MOPOpenAppPlatformType_WechatSession? WXSceneSession:WXSceneTimeline;
            BOOL sendState =  [WXApi sendReq:wxReq];
            if (!sendState) {
                MPB_OpenAppResp *mResp = [[MPB_OpenAppResp alloc] init];
                mResp.source = @"weixin";
                if (![WXApi isWXAppInstalled]) {
                    mResp.code = MOPOpenAppResponseStatusCodeAppUninstall;
                }else if (![WXApi isWXAppSupportApi]){
                    mResp.code = MOPOpenAppResponseStatusCodeAppUnSupport;
                }else{
                    mResp.code = MOPOpenAppResponseStatusCodeSendFail;
                }
                if (error) { error(mResp); }
            }
            [MPB_HUD mopLoadingCancelOnView:nil];
        });
    });
}

+ (void)getSocialAppUserInfoPlatform:(MOPOpenAppPlatformType)type{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"maopuxiaoshuo";
    [WXApi sendReq:req];
}



- (void)p_getAccess_token:(NSString *)code{
    NSString *str =[NSString stringWithFormat:GetWechatAccess_tokenApi,MPB_Config.wechatAppid,MPB_Config.wechatSecret,code];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:str];
        NSString *str2 = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic=  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *openid = dic[@"openid"];
                NSString *access_token = dic[@"access_token"];
                [self p_getUserInfoWithAccess_token:access_token openid:openid];
            }
        });
    });
}

- (void)p_getUserInfoWithAccess_token:(NSString *)token openid:(NSString *)openid{
    NSString *url = [NSString stringWithFormat:GetWechatUserInfoApi,token,openid];
    [MPB_NetWorkManager simpleGet:url callBack:^(MPB_ResponseModel *responseModel) {
        if ([responseModel requestSuccess]) {
            NSDictionary *info = (NSDictionary *)responseModel.data;
            MPB_OpenAppAuthResp *resp = [[MPB_OpenAppAuthResp alloc] init];
            resp.code = MOPOpenAppResponseStatusCodeSuccess;
            resp.originalInfo = info;
            resp.access_token = token;
            resp.openid = openid;
            resp.nickname = info[@"nickname"];
            resp.gender = info[@"sex"];
            resp.portrait = info[@"headimgurl"];
            resp.source = @"weixin";
            if (self.handelResp) {
                self.handelResp(resp);
            }
        }
    }];
}

//WXApiDelegate
- (void)onReq:(BaseReq *)req{
}

- (void)onResp:(BaseResp *)resp{
    if (resp.errCode == WXSuccess) {
        if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
            MPB_OpenAppResp *mResp = [[MPB_OpenAppResp alloc] init];
            mResp.source = @"weixin";
            if (self.handelResp) {self.handelResp(mResp);}
        }else if ([resp isKindOfClass:[SendAuthResp class]]){
            [self p_getAccess_token:((SendAuthResp *)resp).code];
        }
    }else{
        MPB_OpenAppResp *mResp = [[MPB_OpenAppResp alloc] init];
        mResp.source = @"weixin";
        if (resp.errCode == WXSuccess) {
            mResp.code = MOPOpenAppResponseStatusCodeSuccess;
        }else if (resp.errCode == WXErrCodeUserCancel ){
            mResp.code = MOPOpenAppResponseStatusCodeUserCancel;
        }else if (resp.errCode == WXErrCodeAuthDeny){
            mResp.code = MOPOpenAppResponseStatusCodeAuthDeny;
        }else if (resp.errCode == WXErrCodeUnsupport){
            mResp.code = MOPOpenAppResponseStatusCodeAppUnSupport;
        }else{
            mResp.code = MOPOpenAppResponseStatusCodeSendFail;
        }
        if (self.handelResp) {self.handelResp(mResp);}
    }
}


@end
