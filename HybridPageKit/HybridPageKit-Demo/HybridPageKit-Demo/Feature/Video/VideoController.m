//
// VideoController.m
//
// Copyright (c) 2019 dequanzhu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


#import "VideoController.h"
#import "VideoModel.h"
#import "VideoView.h"

@implementation VideoController

- (nullable NSArray<Class> *)supportComponentModelClass {
    return @[[VideoModel class]];
}

- (nullable Class)reusableComponentViewClassWithModel:(HPKModel *)componentModel {
    return [VideoView class];
}

- (void)controllerViewDidAppear {
    // 进入当前页面
    // 视频相关可以从悬浮逻辑，重新attach到页面位置上
}

- (void)controllerViewDidDisappear {
    // 离开当前页面
    // 视频相关可以变成悬浮窗口悬浮
}

//component scroll
- (void)scrollViewWillDisplayComponentView:(HPKView *)componentView
                            componentModel:(HPKModel *)componentModel {
    [((VideoView *)componentView) layoutWithData:(VideoModel *)componentModel];

    //播放逻辑
}

- (void)scrollViewEndDisplayComponentView:(HPKView *)componentView
                           componentModel:(HPKModel *)componentModel {
    // 自动播放的可以停止播放，暂停
    // 也可以变成悬浮窗口悬浮
}

- (void)scrollViewWillPrepareComponentView:(HPKView *)componentView
                            componentModel:(HPKModel *)componentModel {
    // 视频相关的预加载及预处理
    // 提高视频加载速度，减少loading时间
}

@end
