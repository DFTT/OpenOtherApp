//
//  MPB_SocialShareSheet.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/11.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppReq.h"
#import "MPB_OpenAppConst.h"
#import "MPB_PopoverViewController.h"
@interface MPB_SocialShareSheet : MPB_PopoverViewController
@end

@interface MPB_SocialShareSheet(ShareAlter)

//!@brief 弹出分享框,
//!@param presentingController 模态控制器
//!@param configure 配置分享内容
//!@param completion 分享完成回调
+ (void)alertController:(UIViewController *)presentingController
              configure:(MPB_OpenAppReq *(^)(MPB_OpenAppReq*))configure
             completion:(void(^)(NSError *, MOPOpenAppPlatformType))completion;
@end
