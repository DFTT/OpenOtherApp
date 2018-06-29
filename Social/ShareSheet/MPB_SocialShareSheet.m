//
//  MPB_SocialShareSheet.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/11.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_SocialShareSheet.h"
#import "MPB_OpenAppManager.h"
#import "MPB_CommonHeader.h"
#import "MPB_SocialPlatformView.h"
#import "MPB_HUD.h"
#import "MPB_SocialShareResultAlterView.h"
#import "MPB_NetWorkManager+Connect.h"
#import "MPB_Helper.h"
@interface MPB_SocialShareSheet ()<MOPOpenAppManagerDelegate, MPB_SocialPlatformViewDelegate, MPB_SocialPlatformViewDatasource>
@property (nonatomic) MPB_OpenAppReq  *reqModel;
@property (nonatomic) NSMutableArray *effectivePlatforms;
@property (nonatomic, copy) void(^completion)(NSError *,MOPOpenAppPlatformType);
@end
@implementation MPB_SocialShareSheet

- (void)viewDidLoad {
    [super viewDidLoad];
    ((MPB_SocialPlatformView *)self.popoverView).delegate = self;
    ((MPB_SocialPlatformView *)self.popoverView).datasource = self;
}


- (NSMutableArray *)effectivePlatforms{
    if (!_effectivePlatforms) {
        _effectivePlatforms = [[NSMutableArray alloc] init];
        if ([MPB_OpenAppManager isAppInstalled:MOPOpenAppPlatformType_WechatSession]) {
            [_effectivePlatforms addObject:@(MOPOpenAppPlatformType_WechatSession)];
            [_effectivePlatforms addObject:@(MOPOpenAppPlatformType_WechatTimeline)];
        }
        if ([MPB_OpenAppManager isAppInstalled:MOPOpenAppPlatformType_QQ]) {
            [_effectivePlatforms addObject:@(MOPOpenAppPlatformType_QQ)];
            [_effectivePlatforms addObject:@(MOPOpenAppPlatformType_Qzone)];
        }
    }
    return _effectivePlatforms;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.effectivePlatforms.count == 0) {
        [self alterResult:@"无可用分享平台" success:NO platform:-1];
        return;
    }
    [(MPB_SocialPlatformView *)self.popoverView reloadData];

}

//MARK: share content

- (void)clickPlatformActionType:(MOPOpenAppPlatformType)type{
    [MPB_OpenAppManager shareToPlatform:type
                         delegate:self
                               shareReq:self.reqModel];
}

//MARK: platforms
- (void)platform_qq:(UIView *)view{
    [self clickPlatformActionType:MOPOpenAppPlatformType_QQ];
    [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
        m.buttonid = Share_Platform_QQ;
    }];
}

- (void)platform_qzone:(UIView *)view{
    [self clickPlatformActionType:MOPOpenAppPlatformType_Qzone];
    [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
        m.buttonid = Share_Platform_Qzone;
    }];
}

- (void)platform_wechatSession:(UIView *)view{
    [self clickPlatformActionType:MOPOpenAppPlatformType_WechatSession];
    [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
        m.buttonid = Share_Platform_WechatSession;
    }];
}

- (void)platform_wechatTimeline:(UIView *)view{
    [self clickPlatformActionType:MOPOpenAppPlatformType_WechatTimeline];
    [MPB_LogHelper trackClickLog:^(MPB_ClickLogModel *m) {
        m.buttonid = Share_Platform_WechatTimeline;
    }];
}

- (void)platform_cancel:(UIView *)view{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)shouldShareabelPlatforms:(UIView *)view{
    return self.effectivePlatforms;
}


//MARK: Manager delegate
- (void)mopOpenAppCompletionHandeler:(MPB_OpenAppResp *)resp{
    NSString *message;
    if (resp.code == MOPOpenAppResponseStatusCodeSuccess) {
        message = @"分享成功";
        [self alterResult:message success:YES platform:resp.platform];
    }else{
        if (resp.code == MOPOpenAppResponseStatusCodeUserCancel) {
            message = @"取消分享";
        }else if (resp.code == MOPOpenAppResponseStatusCodeAuthDeny){
            message = @"授权失败";
        }else{
            message = @"分享失败";
        }
        [self alterResult:message success:NO platform:resp.platform];
    }
}

//MARK: error
- (void)alterResult:(NSString *)mes success:(BOOL)success platform:(MOPOpenAppPlatformType)platform{
    if (self.containerView) {
        MPB_SocialShareResultAlterView *alt = [[MPB_SocialShareResultAlterView alloc] initWithMessage:mes statu:success];
        [self.containerView addSubview:alt];
        [alt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.containerView);
            make.width.mas_equalTo(185);
        }];
        alt.layer.cornerRadius = 5;
        alt.layer.masksToBounds = true;
        alt.backgroundColor =  HEXACOLOR(0x000000, .5);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.completion) {
            self.completion(success?nil:[[NSError alloc] initWithDomain:@"失败" code:-1 userInfo:nil],platform);
        }
    });
}

- (void)dealloc{
    
}

@end


@implementation MPB_SocialShareSheet(ShareAlter)
+ (void)alertController:(UIViewController *)presentingController  configure:(MPB_OpenAppReq *(^)(MPB_OpenAppReq *))configure completion:(void (^)(NSError *,MOPOpenAppPlatformType))completion{
    if ([MPB_NetWorkManager networkDisconnected]) {
        [MPB_HUD hudShowAtView:presentingController.view message:@"网络异常，请稍后重试"];
        return;
    }
    MPB_SocialShareSheet *ctl = [[MPB_SocialShareSheet alloc] init];
    if (configure) {
        MPB_OpenAppReq *model = [[MPB_OpenAppReq alloc] init];
        configure(model);
        ctl.reqModel = model;
    }
    ctl.completion = completion;
    
    MPB_SocialPlatformView *view = [[MPB_SocialPlatformView alloc] init];
    ctl.popoverView = view;
    ctl.popoverViewFrame = CGRectMake(0, kSCREENH_HEIGHT-KBottomConstraints(169), kSCREEN_WIDTH, KBottomConstraints(169));
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *pr = presentingController;
        if (!pr) {
            pr = [UIApplication sharedApplication].keyWindow.rootViewController ;
        }
        [pr presentViewController:ctl animated:YES completion:nil];
    });
}
@end

