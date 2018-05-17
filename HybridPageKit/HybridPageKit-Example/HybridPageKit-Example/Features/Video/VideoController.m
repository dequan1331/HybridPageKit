//
//  VideoController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "VideoController.h"
#import "VideoModel.h"
#import "VideoView.h"

@implementation VideoController
-(BOOL)shouldResponseWithComponentView:(__kindof UIView *)componentView
                         componentModel:(HPKModel *)componentModel{
    return [componentView class] == [VideoView class] && [componentModel class] == [VideoModel class];
}

- (void)controllerViewDidAppear:(__kindof HPKAbstractViewController *)controller{
    // 进入当前页面
    // 视频相关可以从悬浮逻辑，重新attach到页面位置上
}

- (void)controllerViewDidDisappear:(__kindof HPKAbstractViewController *)controller{
    // 离开当前页面
    // 视频相关可以变成悬浮窗口悬浮
}

//data
- (void)controller:(__kindof HPKAbstractViewController *)controller
    didReceiveData:(NSObject *)data{
    //可以通过数据&数据中的开关，对视频相关逻辑进行处理
}

//component scroll
- (void)scrollViewWillDisplayComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    [((VideoView *)componentView) layoutWithData:(VideoModel *)componentModel];
    
    //播放逻辑
}

- (void)scrollViewEndDisplayComponentView:(__kindof UIView *)componentView
                           componentModel:(HPKModel *)componentModel{
    // 自动播放的可以停止播放，暂停
    // 也可以变成悬浮窗口悬浮
}

- (void)scrollViewWillPrepareComponentView:(__kindof UIView *)componentView
                            componentModel:(HPKModel *)componentModel{
    // 视频相关的预加载及预处理
    // 提高视频加载速度，减少loading时间
}

@end
