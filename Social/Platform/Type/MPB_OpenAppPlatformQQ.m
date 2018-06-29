//
//  MPB_OpenAppPlatformQQ.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppPlatformQQ.h"
#import "MPB_OpenAppReq.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "MPB_Helper.h"

@interface MPB_OpenAppPlatformQQ()<QQApiInterfaceDelegate,TencentSessionDelegate>
@property (nonatomic) TencentOAuth *tencentOAuth;
@end
@implementation MPB_OpenAppPlatformQQ
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static MPB_OpenAppPlatformQQ *qq;
    dispatch_once(&onceToken, ^{
        qq = [[MPB_OpenAppPlatformQQ alloc] init];
    });
    return qq;
}

+ (void)registerApps{
    MPB_OpenAppPlatformQQ *qq = [MPB_OpenAppPlatformQQ shareInstance];
    qq.tencentOAuth =  [[TencentOAuth alloc] initWithAppId:MPB_Config.qqAppid andDelegate:qq];
}

+ (BOOL)isAppInstalled{
    return ([QQApiInterface isQQInstalled]&&[QQApiInterface isQQSupportApi]);
}

+ (BOOL)handleOpenUrl:(NSURL *)url completion:(void (^)(MPB_OpenAppResp *))completion{
    MPB_OpenAppPlatformQQ *qq = [MPB_OpenAppPlatformQQ shareInstance];
    qq.handelResp =  completion;
    [QQApiInterface handleOpenURL:url delegate:qq];
    return [TencentOAuth HandleOpenURL:url];
}

+ (void)shareReq:(MPB_OpenAppReq *)req type:(MOPOpenAppPlatformType)type error:(void (^)(MPB_OpenAppResp *))error{
    NSString *title = req.title;
    NSString *dec = req.des.length>100?[req.des substringToIndex:100]:req.des;
    NSURL *link = [NSURL URLWithString:[MPB_Helper urlEncode:req.qq]];
    QQApiNewsObject*  obj;
    if (req.imageUrl) {
        obj  = [QQApiNewsObject objectWithURL:link
                                        title:title
                                  description:dec
                              previewImageURL:[NSURL URLWithString:req.imageUrl]];
    }else{
        NSData *imageData = UIImageJPEGRepresentation(req.image?:[UIImage imageNamed:MOPDefaultShareAppIcon], 1.0);
        obj  = [QQApiNewsObject objectWithURL:link
                                        title:title
                                  description:dec
                              previewImageData:imageData];
    }
  
    SendMessageToQQReq *qqReq = [SendMessageToQQReq reqWithContent:obj];
    QQApiSendResultCode resultCode = type == MOPOpenAppPlatformType_QQ? [QQApiInterface sendReq:qqReq]:[QQApiInterface SendReqToQZone:qqReq];
    [self handleApiSendResult:resultCode error:error];
}

+ (void)handleApiSendResult:(QQApiSendResultCode)code error:(void (^)(MPB_OpenAppResp *))error{
    if (code == EQQAPISENDSUCESS) {
        return;
    }
    MPB_OpenAppResp *mResp = [[MPB_OpenAppResp alloc] init];
    mResp.source = @"tencent";
    if (![QQApiInterface isQQInstalled]) {
        mResp.code = MOPOpenAppResponseStatusCodeAppUninstall;
    }else if (![QQApiInterface isQQSupportApi]){
        mResp.code = MOPOpenAppResponseStatusCodeAppUnSupport;
    }else{
        mResp.code = MOPOpenAppResponseStatusCodeSendFail;
    }
    if (error) { error(mResp);}
}

+ (void)getSocialAppUserInfoPlatform:(MOPOpenAppPlatformType)type{
    MPB_OpenAppPlatformQQ *qq = [MPB_OpenAppPlatformQQ shareInstance];
    [qq.tencentOAuth authorize:@[kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]];
}

//MARK:QQApiInterfaceDelegate
- (void)isOnlineResponse:(NSDictionary *)response {}
- (void)onReq:(QQBaseReq *)req {}

- (void)onResp:(QQBaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        NSString *result = resp.result;
        MPB_OpenAppResp *mResp = [[MPB_OpenAppResp alloc] init];
        mResp.source = @"tencent";
        if ([result isEqualToString:@"0"]) {
            mResp.code = MOPOpenAppResponseStatusCodeSuccess;
        }else if ([result isEqualToString:@"-4"]){
            mResp.code = MOPOpenAppResponseStatusCodeUserCancel;
        }else{
            mResp.code = MOPOpenAppResponseStatusCodeSendFail;
        }
        if (self.handelResp) { self.handelResp(mResp);  }
    }
}

//MARK: TencentSessionDelegate
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken) {
        [self.tencentOAuth getUserInfo];
    }
}
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        MPB_OpenAppResp *resp = [[MPB_OpenAppResp alloc] init];
        resp.source = @"tencent";
        resp.code = MOPOpenAppResponseStatusCodeUserCancel;
        if (self.handelResp) {
            self.handelResp(resp);
        }
    }
}
- (void)tencentDidNotNetWork {}
- (void)getUserInfoResponse:(APIResponse *)response{
    NSDictionary *info = response.jsonResponse;
    MPB_OpenAppAuthResp *resp = [[MPB_OpenAppAuthResp alloc] init];
    resp.code = MOPOpenAppResponseStatusCodeSuccess;
    resp.originalInfo = info;
    resp.access_token = self.tencentOAuth.accessToken;
    resp.openid = self.tencentOAuth.openId;
    resp.nickname = info[@"nickname"];
    resp.gender = [info[@"gender"] isEqualToString:@"男"]?@"1":@"0";
    resp.portrait = info[@"figureurl_qq_2"];
    resp.source = @"tencent";
    if (self.handelResp) {
        self.handelResp(resp);
    }
}
- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth{
    return YES;
}

@end
