//
//  MPB_SocialPlatformView.h
//  MaoPuBook
//
//  Created by 古月木四点 on 2017/12/15.
//  Copyright © 2017年 gaoxin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPB_SocialPlatformViewDelegate;
@protocol MPB_SocialPlatformViewDatasource;
@interface MPB_SocialPlatformView : UIView
@property (nonatomic, weak) id<MPB_SocialPlatformViewDelegate>delegate;
@property (nonatomic, weak) id<MPB_SocialPlatformViewDatasource>datasource;
- (void)reloadData;
@end

@protocol MPB_SocialPlatformViewDelegate<NSObject>
- (void)platform_cancel:(UIView *)view;
- (void)platform_qq:(UIView *)view;
- (void)platform_wechatSession:(UIView *)view;
- (void)platform_wechatTimeline:(UIView *)view;
- (void)platform_qzone:(UIView *)view;
//- (void)platform_weibo:(MPB_SocialPlatformView *)view;
@end

@protocol MPB_SocialPlatformViewDatasource<NSObject>
- (NSArray *)shouldShareabelPlatforms:(UIView *)view;
@end
