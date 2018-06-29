//
//  MPB_OpenAppConst.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/15.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppConst.h"

NSString *const MOPAppShareDefaultText = @"猫扑小说，书币福利送不停，你一定会爱上它！";
NSString *const MOPAppshareDefaultDesc = @"猫扑20年，与您一起开启移动阅读新体验";
NSString *const GetWechatAccess_tokenApi =  @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code";
NSString *const GetWechatUserInfoApi = @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@";
NSString *const GetWeiboUserInfoApi = @"https://api.weibo.com/2/users/show.json?access_token=%@&uid=%@";
