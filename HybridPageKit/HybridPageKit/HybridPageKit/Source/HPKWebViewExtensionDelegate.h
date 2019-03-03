//
// HPKWebViewExtensionDelegate.h
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


#import <WebKit/WebKit.h>
#import "HPKControllerProtocol.h"

typedef void (^HPKWebViewMainNavDelegateScrollBlock)(CGPoint offset);
typedef void (^HPKWebViewMainNavDelegateContentSizeChangeBlock)(NSValue *newValue, NSValue *oldValue);

@interface HPKWebViewExtensionDelegate : NSObject<WKNavigationDelegate>

/**
 使用webview navigation delegate扩展，优化展示逻辑

 @param originalDelegate webview原navigation delegate，之后作为main delegate
 @param navigationDelegates 广播webview响应事件的接收对象
 */
- (instancetype)initWithOriginalDelegate:(NSObject<HPKDefaultWebViewProtocol> *)originalDelegate
                     navigationDelegates:(NSArray<NSObject<HPKDefaultWebViewProtocol> *> *)navigationDelegates;

/**
 设置对应的webview，承接webview的navigation delegate

 @param contentSizeChangeBlock 监听webview contentSize 变化时的回调
 */
- (void)configWebView:(__kindof WKWebView *)webView contentSizeChangeBlock:(HPKWebViewMainNavDelegateContentSizeChangeBlock)contentSizeChangeBlock;

/**
 优化展示上次阅读位置

 @param lastReadPositionY 上次阅读位置 offset Y
 @param scrollBlock 滚动到响应offset block，多scrollView嵌套时处理
 */
- (void)configWebViewLastReadPositionY:(CGFloat)lastReadPositionY
                           scrollBlock:(HPKWebViewMainNavDelegateScrollBlock)scrollBlock;

/**
 广播webview布局web component
 */
- (void)triggerRelayoutWebComponentEvent;

@end
