//
//  MPB_OpenAppConst.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/15.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//第三方分享回调code 码
typedef NS_ENUM(NSUInteger, MOPOpenAppResponseStatusCode) {
    MOPOpenAppResponseStatusCodeSuccess                 = 0,  // 成功
    MOPOpenAppResponseStatusCodeUserCancel              = -1, // 取消
    MOPOpenAppResponseStatusCodeAuthDeny                = -2, // 授权失败
    MOPOpenAppResponseStatusCodeSendFail                = -3, // 分享失败
    MOPOpenAppResponseStatusCodeAppUninstall            = -4, // app 未安装
    MOPOpenAppResponseStatusCodeAppUnSupport            = -5,  // 当前版本 app 不支持
};

//第三方分享平台
typedef NS_ENUM(NSInteger, MOPOpenAppPlatformType) {
    MOPOpenAppPlatformType_None = -1,
    MOPOpenAppPlatformType_WechatSession,       // 微信好友
    MOPOpenAppPlatformType_WechatTimeline,      // 微信朋友圈
    MOPOpenAppPlatformType_QQ,                  // QQ好友
    MOPOpenAppPlatformType_Qzone,               // QQ空间
    MOPOpenAppPlatformType_Weibo                // 新浪微博
};

//软件分享 默认文字
FOUNDATION_EXTERN NSString *const MOPAppShareDefaultText;
FOUNDATION_EXPORT NSString *const MOPAppshareDefaultDesc;
//微信 api
FOUNDATION_EXTERN NSString *const GetWechatAccess_tokenApi;
FOUNDATION_EXTERN NSString *const GetWechatUserInfoApi;
//微博 api
FOUNDATION_EXTERN NSString *const GetWeiboUserInfoApi;

#define MOPShareBookDefaultText(bookname) [NSString stringWithFormat:@"好书就要和值得的人分享：《%@》",bookname]
#define MOPDefaultShareAppIcon  [[[[NSBundle mainBundle] infoDictionary]  valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject]



