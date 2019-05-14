//
// HPKDefaultWebViewControl.h
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


#import "HPKWebView.h"
#import "HPKControllerProtocol.h"

@class HPKPageHandler;

@interface HPKDefaultWebViewControl : NSObject<HPKControllerProtocol>
/**
 默认内置的webview
 */
@property (nonatomic, strong, readonly) __kindof HPKWebView *defaultWebView;

/**
 默认内置webview对应的model
 */
@property (nonatomic, strong, readonly) HPKModel *defaultWebViewModel;

/**
 生成默认的webview，webviewModel以及navigation delegate扩展

 @param detailHandler HPKPageHandler
 @param webViewClass webview的class，应该是HPKWebView的子类
 @param defaultWebViewIndex webview在container中的index
 */
- (instancetype)initWithDetailHandler:(HPKPageHandler *)detailHandler
                  defaultWebViewClass:(Class)webViewClass
                  defaultWebViewIndex:(NSInteger)defaultWebViewIndex;

/**
 重置defaultWebview,生成新的webview，并清理复用回收池
 */
- (void)resetWebView;

/**
 webView contentSize变化回调
 */
- (void)webviewContentSizeChange:(__kindof HPKWebView *)webView
                         newSize:(CGSize)newSize
                         oldSize:(CGSize)oldSize;

@end
