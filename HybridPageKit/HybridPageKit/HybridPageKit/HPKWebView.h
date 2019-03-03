//
// HPKWebView.h
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
#import "HPKViewProtocol.h"

@interface HPKWebView : WKWebView<HPKViewProtocol>

/**
 标志当前webview禁止重用，直接销毁
 */
@property (nonatomic, assign, readwrite) BOOL invalidForReuse;

/**
 webView 即将离开回收池，初始化设置
 */
- (void)componentViewWillLeavePool __attribute__((objc_requires_super));

/**
 webView 即将进入回收池，清除自定义属性状态等
 */
- (void)componentViewWillEnterPool __attribute__((objc_requires_super));

/**
 清理webview的BackForwardList，防止重用时展示上次页面
 */
- (void)clearBackForwardList;

@end

//_______________________________________________________________________________________________________________
//_______________________________________________________________________________________________________________

typedef void (^HPKWebViewJSCompletionBlock)(NSObject *result);

@interface HPKWebView (extension)

/**
 执行js，retain self 防止crash
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script;

/**
 执行js，retain self 防止crash
 明确result类型，null -> string, 返回NSObject类型
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(HPKWebViewJSCompletionBlock)block;

/**
 手动设置cookies
 */
- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate
          completionBlock:(HPKWebViewJSCompletionBlock)completionBlock;

/**
 删除相应name的cookie
 */
- (void)deleteCookiesWithName:(NSString *)name completionBlock:(HPKWebViewJSCompletionBlock)completionBlock;

/**
 获取全部通过setCookieWithName注入的cookieName
 */
- (NSSet<NSString *> *)getAllCustomCookiesName;

/**
 删除所有通过setCookieWithName注入的cookie
 */
- (void)deleteAllCustomCookies;

@end

//_______________________________________________________________________________________________________________
//_______________________________________________________________________________________________________________

@interface HPKWebView (secondaryDelegate)

/**
 使用main & secondary delegate
 @param useDefaultUIDelegate 是否自动处理UIDelegate
 */
- (void)useExternalNavigationDelegateAndWithDefaultUIDelegate:(BOOL)useDefaultUIDelegate;

/**
 设置main navigation delegate，webView只有唯一一个
 */
- (void)setMainNavigationDelegate:(NSObject<WKNavigationDelegate> *)mainDelegate;

/**
 设置secondary navigation delegate，可以有任意多个
 */
- (void)addSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate;

/**
 删除某个secondary navigation delegate
 */
- (void)removeSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate;

/**
 删除全部secondary navigation delegate
 */
- (void)removeAllSecondaryNavigationDelegates;

@end
