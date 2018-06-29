//
//  MPB_OpenAppReq.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MaoPuBook-Swift.h"
@interface MPB_OpenAppReq : NSObject
@property (nonatomic) NSString *title; // 标题
@property (nonatomic) NSString *des; // 内容
@property (nonatomic) NSString *imageUrl; // 图片链接
@property (nonatomic) UIImage  *image; // 图片数据
@property (nonatomic) NSString *webLink; // 地址
@property (nonatomic) ShareDetalModel *shareUrlModel;

@property (nonatomic,readonly) NSString *qq; // 地址
@property (nonatomic,readonly) NSString *wx; // 地址


@end
