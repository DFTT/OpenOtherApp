//
//  MPB_OpenAppReq.m
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/13.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import "MPB_OpenAppReq.h"

@implementation MPB_OpenAppReq
-(NSString *)qq{
    if(_shareUrlModel.qq){
        return _shareUrlModel.qq;
    }
    return _webLink;
}
- (NSString *)wx{
    if(_shareUrlModel.wx){
        return _shareUrlModel.wx;
    }
    return _webLink;
}
@end
