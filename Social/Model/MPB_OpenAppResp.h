//
//  MPB_OpenAppResp.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPB_OpenAppConst.h"
@interface MPB_OpenAppResp : NSObject
@property (nonatomic, assign) MOPOpenAppResponseStatusCode code;
@property (nonatomic, assign) MOPOpenAppPlatformType platform;
@property (nonatomic, copy) NSString *source;
@end

//用户授权登录获取第三方信息
@interface MPB_OpenAppAuthResp: MPB_OpenAppResp
@property (nonatomic) NSString *access_token;
@property (nonatomic) NSString *openid;
@property (nonatomic) NSString *nickname;
@property (nonatomic) NSString *gender;
@property (nonatomic) NSString *birthday;
@property (nonatomic) NSString *portrait;
@property (nonatomic) NSDictionary *originalInfo; // 第三方 app 返回的原始信息
@end
