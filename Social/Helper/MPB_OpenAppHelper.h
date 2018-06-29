//
//  MPB_OpenAppHelper.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2018/1/3.
//  Copyright © 2018年 gaoxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPB_ShareLogModel.h"
#import "MaoPuBook-Swift.h"
@class MPB_BookModel;
@interface MPB_OpenAppHelper : NSObject

//!@brief 分享app
+ (void)shareApp:(UIViewController *)viewController
  successHandler:(void(^)(void))handler;

//!@brief 分享小说
+ (void)shareNovel:(MPB_BookModel *)book
         sectionid:(NSString *)sectionid
    viewController:(UIViewController *)viewController
    successHandler:(void(^)(void))handler;

//!@brief 分享签到翻牌奖励
+ (void)shareSiginTurnCard:(NSString *)title
            viewController:(UIViewController *)viewController
            successHandler:(void(^)(void))handler;

//!@biref H5 分享
+ (void)shareFromH5:(NSDictionary *)info
     viewController:(UIViewController *)viewController
     successHandler:(void(^)(NSDictionary *))handler;

//!@biref 分享
+(void)simpleShare:(NSString *)title
               url:(NSString*)url
     shareUrlModel:(ShareDetalModel*)shareUrlModel
          imageUrl:(NSString*)imageUrl
               des:(NSString*)des
    viewController:(UIViewController *)viewController
    successHandler:(void (^)(void))handler;
@end
