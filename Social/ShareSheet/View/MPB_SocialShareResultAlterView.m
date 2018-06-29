//
//  MPB_SocialShareResultAlterView.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/19.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_SocialShareResultAlterView.h"
#import "MPB_CommonHeader.h"
@implementation MPB_SocialShareResultAlterView
- (instancetype)initWithMessage:(NSString *)mes statu:(BOOL)statu
{
    self = [super init];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: statu? @"share_alter_success":@"share_alter_failure"]];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(18);
            make.centerX.equalTo(self);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = HEXCOLOR(0xffffff);
        label.text = mes;
        label.font = kSYSTEMFONT(18);
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(imageView.mas_bottom).offset(8);
            make.bottom.equalTo(self).offset(-21);
        }];
        
    }
    return self;
}

@end
