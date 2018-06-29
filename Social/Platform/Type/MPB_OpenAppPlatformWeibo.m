//
//  MPB_OpenAppPlatformWeibo.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2018/2/9.
//  Copyright © 2018年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppPlatformWeibo.h"
#import <Weibo_SDK/WeiboSDK.h>
#import "MPB_OpenAppReq.h"
#import "MPB_NetWorkManager.h"
#import "MPB_Helper.h"
@interface MPB_OpenAppPlatformWeibo()<WeiboSDKDelegate>
@end
@implementation MPB_OpenAppPlatformWeibo
+ (void)registerApps{
    [WeiboSDK registerApp:MPB_Config.weiboAppkey];
}

+ (BOOL)isAppInstalled{
    return [WeiboSDK isWeiboAppInstalled];
}

+ (BOOL)handleOpenUrl:(NSURL *)url completion:(void (^)(MPB_OpenAppResp *))completion{
    MPB_OpenAppPlatformWeibo *weibo = [[MPB_OpenAppPlatformWeibo alloc] init];
    weibo.handelResp = completion;
    return [WeiboSDK handleOpenURL:url delegate:weibo];
}

+ (void)getSocialAppUserInfoPlatform:(MOPOpenAppPlatformType)type{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = MPB_Config.weiboRedirectURI;
    request.scope = @"all";
    request.userInfo = @{};
    [WeiboSDK sendRequest:request];
    
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            NSString *userid = [(WBAuthorizeResponse *)response userID];
            NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
            [self __getUserInfoWithUserid:userid accessToken:accessToken];
        }else {
            MPB_OpenAppResp *resp = [[MPB_OpenAppResp alloc] init];
            resp.source = @"weibo";
            if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
                resp.code = MOPOpenAppResponseStatusCodeUserCancel;
            }else if (resp.code == WeiboSDKResponseStatusCodeAuthDeny){
                resp.code = MOPOpenAppResponseStatusCodeAuthDeny;
            }else{
                resp.code = MOPOpenAppResponseStatusCodeSendFail;
            }
            if (self.handelResp) {
                self.handelResp(resp);
            }
        }
    }
}

- (void)__getUserInfoWithUserid:(NSString *)userid accessToken:(NSString *)accessToken{
    NSString *str = [NSString stringWithFormat:GetWeiboUserInfoApi,accessToken,userid];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:str];
        NSString *str2 = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [str2 dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic=  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                MPB_OpenAppAuthResp *resp = [[MPB_OpenAppAuthResp alloc] init];
                resp.code = MOPOpenAppResponseStatusCodeSuccess;
                resp.access_token = accessToken;
                resp.openid = userid;
                resp.nickname = dic[@"name"];
                resp.gender = [dic[@"gender"] isEqualToString:@"m"]?@"1":@"0";
                resp.portrait = dic[@"avatar_hd"];
                resp.originalInfo = dic;
                resp.source = @"weibo";
                if (self.handelResp) {
                    self.handelResp(resp);
                }
            }
        });
    });
}

@end
