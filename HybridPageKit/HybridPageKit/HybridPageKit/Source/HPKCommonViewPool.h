//
// HPKCommonViewPool.h
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


#import "HPKViewProtocol.h"
/**
 * 底层页Components复用回收池
 */
@interface HPKCommonViewPool : NSObject

+ (HPKCommonViewPool *)sharedInstance;

/**
 从回收池中根据class取View
 */
- (HPKView *)dequeueComponentViewWithClass:(Class)viewClass;

/**
 回收相应view
 */
- (void)enqueueComponentView:(HPKView *)componentView;

/**
 回收某个view上的全部components View
 */
- (void)enqueueAllComponentViewsOfSuperView:(__kindof UIView *)superView;

/**
 重置View状态
 */
- (void)resetVisibleComponentViewState:(HPKView *)componentView;

/**
 清理全部复用View
 */
- (void)clearAllReusableComponentViews;
@end
