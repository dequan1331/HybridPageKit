//
// HPKViewProtocol.h
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


#ifndef HPKViewProtocol_h
#define HPKViewProtocol_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#define HPKView UIView<HPKViewProtocol>

#define ISHPKView(value) ([value conformsToProtocol:@protocol(HPKViewProtocol)])

#define IMP_HPKViewProtocol()                                                                            \
    - (void)setComponentViewId: (NSString *)componentViewId { objc_setAssociatedObject(self, @selector(setComponentViewId:), componentViewId, OBJC_ASSOCIATION_COPY_NONATOMIC); } \
    - (NSString *)componentViewId { return objc_getAssociatedObject(self, @selector(setComponentViewId:)); }

/**
 * 底层页Component组件View的protocol
 * ComponentView需要实现 `IMP_HPKViewProtocol()`
 */
@protocol HPKViewProtocol

@optional
/**
 component在content container中占的高度

 @return view返回自定义高度或view的height，自身或者包含scrollView的返回contentSize
 */
- (CGFloat)componentHeight;

/**
 @return component自身或者包含的scrollView
 */
- (nullable UIScrollView *)componentInnerScrollView;

/**
 componentView 即将离开回收池，初始化layout展示
 */
- (void)componentViewWillLeavePool;

/**
 componentView 即将进入回收池，清理布局状态等
 */
- (void)componentViewWillEnterPool;

/**
 以下使用 `IMP_HPKViewProtocol()` 替代
 */
@required
- (void)setComponentViewId:(NSString *)detailComponentId;
- (NSString *)componentViewId;
@end

NS_ASSUME_NONNULL_END

#endif /* HPKViewProtocol_h */
