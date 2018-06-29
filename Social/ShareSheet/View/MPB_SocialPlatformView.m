//
//  MPB_SocialPlatformView.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/15.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_SocialPlatformView.h"
#import "MPB_CommonHeader.h"
#import "MPB_OpenAppConst.h"
@implementation MPB_SocialPlatformView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xffffff);
        [self p_setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEXCOLOR(0xffffff);
        [self p_setup];
    }
    return self;
}

- (void)p_setup{
    UIButton *cancel = [[UIButton alloc] init];
    [cancel setTitle:@"取 消" forState:UIControlStateNormal];
    [cancel setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
    cancel.titleLabel.font = kSYSTEMFONT(16);
    [self addSubview:cancel];
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).offset(-KBottomConstraints(0));
        make.height.mas_equalTo(50);
    }];
    [cancel addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = MPB_Const.LineColorE8;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(cancel.mas_top);
        make.height.mas_equalTo(kOnePixLineHeight);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)reloadData{
    
    UIView *lastPlatform;
    NSMutableArray *arr1 = [[NSMutableArray alloc] init];
    NSMutableArray *arr2 = [[NSMutableArray alloc] init];
    NSArray *platforms = [self.datasource shouldShareabelPlatforms:self];
    if ([platforms containsObject:@(MOPOpenAppPlatformType_WechatSession)]) {
        [arr1 addObject:@"微信好友"];
        [arr1 addObject:@"朋友圈"];
        [arr2 addObject:@"share_platform_session"];
        [arr2 addObject:@"share_platform_timeline"];
    }
    if ([platforms containsObject:@(MOPOpenAppPlatformType_QQ)]) {
        [arr1 addObject:@"QQ好友"];
        [arr1 addObject:@"QQ空间"];
        [arr2 addObject:@"share_platform_qq"];
        [arr2 addObject:@"share_platform_qzone"];
    }
    
    for (int idx = 0; idx < platforms.count; idx++) {
        UIView *view = [[UIView alloc] init];
        [self addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastPlatform?lastPlatform.mas_right:self);
            make.top.equalTo(self);
            make.bottom.equalTo(self).offset(-50);
            make.width.equalTo(self).multipliedBy(1.0/arr2.count);
        }];
        [self p_creatPlatform:view image:[UIImage imageNamed:arr2[idx]] title:arr1[idx]];
        view.tag = 10000 + [platforms[idx] integerValue];
        lastPlatform = view;
    }
}

- (void)p_creatPlatform:(UIView *)view image:(UIImage *)image title:(NSString*)title{
    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imageview];
    [imageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view).offset(26);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = kSYSTEMFONT(15);
    label.textColor = HEXCOLOR(0x666666);
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(imageview.mas_bottom).offset(6);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tap];
}

- (void)cancelButtonAction:(UIButton *)btn{
    [self.delegate platform_cancel:self];
}

- (void)tapAction:(UIGestureRecognizer *)rec{
    UIView *view = rec.view;
    MOPOpenAppPlatformType type = (MOPOpenAppPlatformType)(view.tag - 10000);
    switch (type) {
        case MOPOpenAppPlatformType_WechatSession:
            [self.delegate platform_wechatSession:self];
            break;
        case MOPOpenAppPlatformType_WechatTimeline:
            [self.delegate platform_wechatTimeline:self];
            break;
        case MOPOpenAppPlatformType_QQ:
            [self.delegate platform_qq:self];
            break;
        case MOPOpenAppPlatformType_Qzone:
            [self.delegate platform_qzone:self];
            break;
        default:
            break;
    }
}

@end
