//
// HPKWebViewPool.h
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

/**
 * 底层页WebView复用回收池
 */
@interface HPKWebViewPool : NSObject

+ (HPKWebViewPool *)sharedInstance;

/**
 获取可复用的WKWebView

 @param webViewClass 可复用的WKWebView Class
 @param webViewHolder webView的持有者，用于自动回收WebView
 @return 可复用的WKWebView
 */
- (__kindof HPKWebView *)dequeueWebViewWithClass:(Class)webViewClass webViewHolder:(NSObject *)webViewHolder;

/**
 回收可复用的WKWebView

 @param webView 可复用的webView
 */
- (void)enqueueWebView:(__kindof HPKWebView *)webView;

/**
 回收并销毁WKWebView，并且将之从回收池里删除

 @param webView 可复用的webView
 */
- (void)removeReusableWebView:(__kindof HPKWebView *)webView;

/**
 销毁全部在回收池中的WebView
 */
- (void)clearAllReusableWebViews;

/**
 销毁在回收池中特定Class的WebView

 @param webViewClass 可复用的webView的类型
 */
- (void)clearAllReusableWebViewsWithClass:(Class)webViewClass;

/**
 重新刷新在回收池中的WebView
 */
- (void)reloadAllReusableWebViews;

@end
