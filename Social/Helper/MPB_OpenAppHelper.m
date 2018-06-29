//
//  MPB_OpenAppHelper.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2018/1/3.
//  Copyright © 2018年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppHelper.h"
#import "MPB_CloudConfigModel.h"
#import "MPB_NetWorkManager.h"
#import "MPB_OpenAppConst.h"
#import "MPB_SocialShareSheet.h"
#import "MPB_BookModel.h"
@implementation MPB_OpenAppHelper

#pragma mark 构造分享url model
//分享书籍 urlModel
+ (ShareDetalModel *)shareBookAppendingHtml:(NSString *)bookid{
    ShareDetalModel *shareModel = MPB_ShareConfig.shareInstance.shareBookUrl;
    NSString* (^configUrl)(NSString *orgUrl) = ^(NSString *orgUrl){
        if (!orgUrl || ![orgUrl hasPrefix:@"http"]) {
            orgUrl = MopBookShareLandingPageHtml;
        }
        orgUrl =  [[orgUrl stringByAppendingString:@"?bookId="] stringByAppendingString:bookid];
        orgUrl = [self __appendPulicParamter:orgUrl];
        orgUrl = [orgUrl stringByAppendingString:@"&qid=xshare&channelCode=xshareapp"];
        return orgUrl;
    };
    shareModel.wx = configUrl(shareModel.wx);
    shareModel.qq = configUrl(shareModel.qq);
    return shareModel;
}
//分享app UrlModel
+ (ShareDetalModel *)shareAppAppendingHtml{
    
    ShareDetalModel *shareModel = MPB_ShareConfig.shareInstance.shareApp;
    NSString* (^configUrl)(NSString *orgUrl) = ^(NSString *orgUrl){
        if (!orgUrl || ![orgUrl hasPrefix:@"http"]) {
            orgUrl = MopAppShareLandingPageHtml;
        }
        orgUrl = [orgUrl hasSuffix:@"?"]? orgUrl:[orgUrl stringByAppendingString:@"?"];
        orgUrl = [self __appendPulicParamter:orgUrl];
        orgUrl = [orgUrl stringByAppendingString:@"&qid=appshare&channelCode=appshareapp"];
        return orgUrl;
    };
    shareModel.wx = configUrl(shareModel.wx);
    shareModel.qq = configUrl(shareModel.qq);
    return shareModel;
}
//翻牌后分享UrlModel
+ (ShareDetalModel *)shareFlopAppendingHtml{
    ShareDetalModel *shareModel = MPB_ShareConfig.shareInstance.shareFlopH5;
    NSString* (^configUrl)(NSString *orgUrl) = ^(NSString *orgUrl){
        if (!orgUrl || ![orgUrl hasPrefix:@"http"]) {
            orgUrl = ShareCoin;
        }
        orgUrl = [orgUrl hasSuffix:@"?"]? orgUrl:[orgUrl stringByAppendingString:@"?"];
        orgUrl = [self __appendPulicParamter:orgUrl];
        orgUrl = [orgUrl stringByAppendingString:@"&qid=fanpaishare&channelCode=fanpaishareapp"];
        return orgUrl;
    };
    shareModel.wx = configUrl(shareModel.wx);
    shareModel.qq = configUrl(shareModel.qq);
    return shareModel;
}

//拼接公告参数
+ (NSString *)__appendPulicParamter:(NSString *)html{
    NSDictionary *public = [[MPB_MopPublicRequestModel alloc]init].modelDic;
    NSMutableArray *keyValueArr = [[NSMutableArray alloc] init];
    for (NSString *key in public.allKeys) {
        if (![key isEqualToString:@"mf_token"]) {
            NSString *str = [NSString stringWithFormat:@"%@=%@",key,public[key]];
            [keyValueArr addObject:str];
        }
    }
    [keyValueArr addObject:[NSString stringWithFormat:@"uid=%@",MPB_Const.uid]];
    NSString *appendingStr = [keyValueArr componentsJoinedByString:@"&"];
    html = [[html stringByAppendingString:@"&"] stringByAppendingString:appendingStr];
    return html;
}

#pragma mark 分享日志
+ (void)shareLogUpload:(void (^)(MPB_ShareLogModel *))configure platform:(NSInteger)platform{
    MPB_ShareLogModel *model = [[MPB_ShareLogModel alloc] init];
    configure(model);
    if (platform == MOPOpenAppPlatformType_QQ
        || platform == MOPOpenAppPlatformType_Qzone) {
        model.platform = @"qq";
    }
    else if (platform == MOPOpenAppPlatformType_WechatSession
             ||platform == MOPOpenAppPlatformType_WechatTimeline){
        model.platform = @"wechat";
    }
    [MPB_NetWorkManager uploadShareLog:model callBack:nil];
}
#pragma mark 根据平台获取分享的url
+(NSString *)__shareUrl:(MOPOpenAppPlatformType) plateform shareUrlModel:(ShareDetalModel*)shareUrlModel{
    if(plateform == MOPOpenAppPlatformType_WechatSession || plateform == MOPOpenAppPlatformType_WechatTimeline){
        return shareUrlModel.wx;
    }else if(plateform == MOPOpenAppPlatformType_QQ || plateform == MOPOpenAppPlatformType_Qzone){
        return shareUrlModel.qq;
    }
    return nil;
}



#pragma mark 分享app
+ (void)shareApp:(UIViewController *)viewController successHandler:(void (^)(void))handler{
    
    ShareDetalModel *shareUrlModel = [MPB_OpenAppHelper shareAppAppendingHtml];
    [self __shareWithTitle:MOPAppShareDefaultText
                  imageUrl:nil
                     image:nil
                       des:MOPAppshareDefaultDesc
                   webLink:nil
             shareUrlModel:shareUrlModel
            viewController:viewController.navigationController
            successHandler:
     ^(MOPOpenAppPlatformType platform) {
         [MPB_OpenAppHelper shareLogUpload:^(MPB_ShareLogModel *model) {
             model.surl = [self __shareUrl:platform shareUrlModel:shareUrlModel];
             model.btype = @"app";
             model.subtype = @"null";
         } platform:platform];
         
         SAFE_BLOCK(handler);
         
         [[MPB_TaskService shareService] finishShareAppTask];
         [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
             m.buttonid = Share_App_Success;
         }];
     }];
}
#pragma mark 分享书籍
+ (void)shareNovel:(MPB_BookModel *)book sectionid:(NSString *)sectionid viewController:(UIViewController *)viewController successHandler:(void (^)(void))handler {
    
    ShareDetalModel *shareUrlModel = [MPB_OpenAppHelper shareBookAppendingHtml:book.bookid];
    [self __shareWithTitle:MOPShareBookDefaultText(book.bookname)
                  imageUrl:book.imgjs
                     image:[[YYImageCache sharedCache] getImageForKey:book.imgjs]
                       des:book.desc
                   webLink:nil
             shareUrlModel:shareUrlModel
            viewController:viewController.navigationController
            successHandler:
     ^(MOPOpenAppPlatformType platform) {
         [MPB_OpenAppHelper shareLogUpload:^(MPB_ShareLogModel *model) {
             model.surl = [self __shareUrl:platform shareUrlModel:shareUrlModel];;
             model.btype = book.bookid;
             model.subtype = sectionid?:@"null";
         } platform:platform];
         
         SAFE_BLOCK(handler);
         
         [[MPB_TaskService shareService] finishShareBook];
         [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
             m.buttonid = Share_Book_Success;
         }];
     }];
}
#pragma mark 翻牌分享
+ (void)shareSiginTurnCard:(NSString *)title viewController:(UIViewController *)viewController successHandler:(void (^)(void))handler{
    ShareDetalModel *shareUrlModel = [MPB_OpenAppHelper shareFlopAppendingHtml];
    [self __shareWithTitle:title
                  imageUrl:nil
                     image:nil
                       des:MOPAppshareDefaultDesc
                   webLink:nil
             shareUrlModel:shareUrlModel
            viewController:viewController.navigationController
            successHandler:
     ^(MOPOpenAppPlatformType platform) {
         [MPB_OpenAppHelper shareLogUpload:^(MPB_ShareLogModel *model) {
             model.surl = [self __shareUrl:platform shareUrlModel:shareUrlModel];;
             model.btype = @"app";
             model.subtype = @"null";
         } platform:platform];
         
         SAFE_BLOCK(handler);
         
         [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
             m.buttonid = Share_TurnCard_Success;
         }];
     }];
}

#pragma mark h5 调用share分享
+ (void)shareFromH5:(NSDictionary *)info viewController:(UIViewController *)viewController successHandler:(void (^)(NSDictionary *))handler{
    NSString *jsonParam = info[@"JsonParam"];
    NSData *data = [jsonParam dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
    if ([info[@"type"] integerValue] == 1) {
        //分享小说
        ShareDetalModel *shareUrlModel = [MPB_OpenAppHelper shareBookAppendingHtml:dic[@"bookid"]];
        [self __shareWithTitle:dic[@"title"]
                      imageUrl:dic[@"imageUrl"]
                         image:[[YYImageCache sharedCache] getImageForKey:dic[@"imageUrl"]]
                           des:dic[@"subTitle"]
                       webLink:nil
                 shareUrlModel:shareUrlModel
                viewController:viewController
                successHandler:
         ^(MOPOpenAppPlatformType platform) {
             [MPB_OpenAppHelper shareLogUpload:^(MPB_ShareLogModel *model) {
                 model.surl = [self __shareUrl:platform shareUrlModel:shareUrlModel];
                 model.btype = dic[@"bookid"];
                 model.subtype = @"null";
             } platform:platform];
             SAFE_BLOCK(handler, dic);
             
             [[MPB_TaskService shareService] finishShareBook];
             [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
                 m.buttonid = Share_Book_Success;
             }];
         }];
    }else if ([info[@"type"] integerValue] == 2){
        //分享活动
        NSDictionary *urlModelDic = dic[@"urlModel"];
        ShareDetalModel *urlShareModel = nil;
        if(urlModelDic){
            urlShareModel = [[ShareDetalModel alloc] init];
            [urlShareModel modelSetWithDictionary:urlModelDic];
        }
        
        [self __shareWithTitle:dic[@"title"]
                      imageUrl:dic[@"imageUrl"]
                         image:nil
                           des:dic[@"subTitle"]
                       webLink:dic[@"url"]
                 shareUrlModel:urlShareModel
                viewController:viewController
                successHandler:
         ^(MOPOpenAppPlatformType platform) {
             SAFE_BLOCK(handler, dic);
         }];
    }
}
#pragma 通用分享方法
+ (void)simpleShare:(NSString *)title
                url:(NSString *)url
      shareUrlModel:(ShareDetalModel*)shareUrlModel
           imageUrl:(NSString *)imageUrl
                des:(NSString *)des
     viewController:(UIViewController *)viewController
     successHandler:(void (^)(void))handler{
    
    [self __shareWithTitle:title imageUrl:imageUrl image:nil des:des webLink:url shareUrlModel:shareUrlModel viewController:viewController successHandler:^(MOPOpenAppPlatformType platform) {
        SAFE_BLOCK(handler);
    }];
}


+ (void)__shareWithTitle:(NSString *)title
                imageUrl:(NSString *)imageUrl
                   image:(UIImage *)image
                     des:(NSString *)des
                 webLink:(NSString *)url
           shareUrlModel:(ShareDetalModel*)shareUrlModel
          viewController:(UIViewController *)viewController
          successHandler:(void(^)(MOPOpenAppPlatformType))handler{
    
    [MPB_SocialShareSheet alertController:viewController configure:^MPB_OpenAppReq *(MPB_OpenAppReq *model) {
        model.title = title;
        model.imageUrl = imageUrl;
        model.image = image;
        model.des = des;
        model.webLink = url;
        model.shareUrlModel = shareUrlModel;
        return model;
    } completion:^(NSError *error, MOPOpenAppPlatformType platform) {
        if (!error) {
            handler(platform);
        }
    }];
}


@end
