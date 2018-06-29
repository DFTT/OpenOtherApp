//
//  MPB_OpenAppResp.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppResp.h"

@implementation MPB_OpenAppResp
- (instancetype)init
{
    self = [super init];
    if (self) {
        _platform = MOPOpenAppPlatformType_None;
    }
    return self;
}
@end

@implementation MPB_OpenAppAuthResp
@end
